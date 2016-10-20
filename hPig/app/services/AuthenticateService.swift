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
}

class AuthenticateService: NSObject, NaverThirdPartyLoginConnectionDelegate {
    static let shared: AuthenticateService = {
        let instance = AuthenticateService()
        return instance
    }()
    
    private let naverConnection: NaverThirdPartyLoginConnection = NaverThirdPartyLoginConnection.getSharedInstance()!
    private weak var viewController: UIViewController? = nil
    private var completionHandler: ((_ isSuccess: Bool) -> Void)? = nil
    private var userMap = [String: User]()
    private var userDataMap = [String: TubeUserInfo]()
    
    func prepare() {
        naverConnection.serviceUrlScheme = kServiceAppUrlScheme
        naverConnection.consumerKey = kConsumerKey
        naverConnection.consumerSecret = kConsumerSecret
        naverConnection.appName = kServiceAppName
        
        naverConnection.isNaverAppOauthEnable = true
        naverConnection.isInAppOauthEnable = true
        naverConnection.delegate = self
        
        user(nil)
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
    
    func tryLogin(viewController: UIViewController, completion: ((_ isSuccess: Bool) -> Void)?) {
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
        
        if let token = naverConnection.accessToken {
            if let user = userMap[token], let info = userDataMap[user.id] {
                callback(info)
            } else {
                var req = URLRequest(url: URL(string: "https://apis.naver.com/nidlogin/nid/getUserProfile.xml")!)
                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                NetService.shared.get(req: req).response { (res) in
                    if let data = res.data, let user = User(data: data) {
                        self.userMap[token] = user
                        self.tubeUser(user.id, completion: completion)
                    } else {
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
    
    func shouldPerform(_ id: String, viewController: UIViewController, session: Session?) -> Bool {
        switch id {
        case "basicStudyFromMyInfo"
        , "basicStudyFromSessionMain"
        , "patternStudyFromSessionMain"
        , "patternStudyFromWorkBook":
            if let item = session {
                if item.isFree {
                    return true
                } else {
                    return isActiveUser()
                }
            } else {
                return false
            }
        default:
            return true
        }
    }
    
    private func isActiveUser() -> Bool {
        if let token = naverConnection.accessToken,
            let user = userMap[token],
            let info = userDataMap[user.id] {
            return info.isActiveUser
        } else {
            // log on
            
            user({ (_) in
                
            })
            
            return false
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
            vc.present(NLoginThirdPartyOAuth20InAppBrowserViewController(request: request), animated: true, completion: nil)
        }
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("2 ==============")
        
        user(nil)

        if let completion = completionHandler {
            completion(true)
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
