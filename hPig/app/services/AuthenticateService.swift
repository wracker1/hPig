//
//  AuthenticateService.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 29..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

enum AuthError: Error {
    case needToLogin
    case unauthorized
}

class AuthenticateService: NSObject, NaverThirdPartyLoginConnectionDelegate {
    static let shared: AuthenticateService = {
        let instance = AuthenticateService()
        return instance
    }()
    
    var userMap = [String: User]()
    var userDataMap = [String: TubeUserInfo]()
    let naverConnection: NaverThirdPartyLoginConnection = NaverThirdPartyLoginConnection.getSharedInstance()!
    
    private weak var viewController: UIViewController? = nil
    private var completionHandler: ((TubeUserInfo?) -> Void)? = nil
    
    func prepare(_ completion: ((TubeUserInfo?) -> Void)?) {
        naverConnection.serviceUrlScheme = kServiceAppUrlScheme
        naverConnection.consumerKey = kConsumerKey
        naverConnection.consumerSecret = kConsumerSecret
        naverConnection.appName = kServiceAppName
        
        naverConnection.isNaverAppOauthEnable = true
        naverConnection.isInAppOauthEnable = true
        naverConnection.delegate = self
        
        user(completion)
    }
    
    func isOn() -> Bool {
        return naverConnection.accessToken != nil
    }
    
    func userId(completion: ((String) -> Void)?) {
        let callback = completion ?? {(_) in }
        
        user { (opt) in
            callback(opt?.id ?? Global.guestId)
        }
    }
    
    func tryLogin(_ viewController: UIViewController, completion: ((TubeUserInfo?) -> Void)?) {
        self.viewController = viewController
        self.completionHandler = completion
        
        naverConnection.requestThirdPartyLogin()
    }
    
    func logout(completion: (() -> Void)?) {
        userMap.removeAll()
        userDataMap.removeAll()
        naverConnection.resetToken()
        
        if let handler = completion {
            handler()
        }
    }
    
    func user(_ completion: ((TubeUserInfo?) -> Void)?) {
        let callback = completion ?? {(_) in }
        
        print(naverConnection.accessToken ?? "empty")
        
        if let token = naverConnection.accessToken {
            if let user = userMap[token], let info = userDataMap[user.id] {
                callback(info)
            } else {
                var req = URLRequest(url: URL(string: "https://apis.naver.com/nidlogin/nid/getUserProfile.xml")!)
                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                NetService.shared.get(req: req).response { (res) in
                    if let data = res.data, let user = User(data: data), user.id != Global.guestId {
                        self.userMap[token] = user
                        self.tubeUser(user.id, completion: completion)
                    } else {
                        self.userMap.removeValue(forKey: self.naverConnection.accessToken)
                        self.naverConnection.requestAccessTokenWithRefreshToken()
                        callback(nil)
                    }
                }
            }
        } else {
            callback(nil)
        }
    }
    
    private func tubeUser(_ id: String, completion: ((TubeUserInfo?) -> Void)?) {
        let callback = completion ?? {(_) in }
        
        NetService.shared.getObject(path: "/svc/api/user/info?id=\(id)", completionHandler: { (res: DataResponse<TubeUserInfo>) in
            if let userInfo = res.result.value {
                self.userDataMap[id] = userInfo
                
                callback(userInfo)
            } else {
                callback(nil)
            }
        })
    }
    
    func shouldPerform(_ id: String, viewController: UIViewController, sender: Any?, session: Session?) -> Bool {
        switch id {
        case "basicStudyFromMyInfo"
        , "basicStudyFromSessionMain"
        , "patternStudyFromSessionMain"
        , "patternStudyFromWorkBook":
            if let item = session {
                if item.isFree {
                    return true
                } else {
                    do {
                        return try isActiveUser()
                    } catch AuthError.needToLogin {
                        AlertService.shared.presentConfirm(
                            viewController,
                            title: "로그인이 필요합니다. 로그인 하시겠습니까?",
                            message: nil,
                            cancel: nil,
                            confirm: {
                                self.tryLogin(viewController, completion: { (success) in
                                    viewController.performSegue(withIdentifier: id, sender: sender)
                                })
                        })
                        
                        return false
                    } catch AuthError.unauthorized {
                        viewController.view.presentToast("이용권을 구매해주세요.")
                        return false
                    } catch let e {
                        viewController.view.presentToast(e.localizedDescription)
                        return false
                    }
                }
            } else {
                return false
            }
        default:
            return true
        }
    }
    
    private func isActiveUser() throws -> Bool {
        if let token = naverConnection.accessToken,
            let user = userMap[token],
            let info = userDataMap[user.id] {
            
            if info.isActiveUser {
                return true
            } else {
                throw AuthError.unauthorized
            }
        } else {
            // log on
            
            user({ (_) in
                
            })
            
            throw AuthError.needToLogin
        }
    }
    
    func processAccessToken(url: URL) -> Bool {
        print("0 ============== \(url)")
        
        if url.scheme ?? "" == "speakingtube" {
            if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true), let queryItems = urlComponents.queryItems {
                print(queryItems)
            }
            
            return true
        } else {
            return false
        }
    }
    
    func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {
        print("1 ==============")
        
        if let vc = viewController {
            let navigator = UINavigationController(rootViewController: NLoginThirdPartyOAuth20InAppBrowserViewController(request: request))
            
            vc.present(navigator, animated: true, completion: nil)
        }
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("2 ==============")
        
        if let completion = completionHandler {
            user(completion)
            self.completionHandler = nil
        }
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("3 ==============")
        
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        print("4 ==============")
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("5 ============== \(oauthConnection), \(error)")
    }
}
