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
    
    private var pushToken: String? = nil
    private var naverUserMap = [String: User]()
    private var tubeUserMap = [String: TubeUserInfo]()
    
    private let tokenKey = "deviceToken"
    private let naverConnection: NaverThirdPartyLoginConnection = NaverThirdPartyLoginConnection.getSharedInstance()!
    
    private weak var viewController: UIViewController? = nil
    private var completionHandler: ((TubeUserInfo?) -> Void)? = nil
    
    private func deviceToken() -> String? {
        return UserDefaults.standard.value(forKey: tokenKey) as? String ?? pushToken
    }
    
    @discardableResult func prepare() -> AuthenticateService {
        self.naverConnection.serviceUrlScheme = kServiceAppUrlScheme
        self.naverConnection.consumerKey = kConsumerKey
        self.naverConnection.consumerSecret = kConsumerSecret
        self.naverConnection.appName = kServiceAppName
        
        self.naverConnection.isNaverAppOauthEnable = true
        self.naverConnection.isInAppOauthEnable = true
        self.naverConnection.delegate = self
        
        return self
    }
    
    @discardableResult func refreshToken() -> AuthenticateService {
        DispatchQueue.global().async {
            if self.isOn() {
                self.naverConnection.requestAccessTokenWithRefreshToken()
            }
        }
        
        return self
    }
    
    func registerAPNSToken(_ token: String) {
        self.pushToken = token
        
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.synchronize()
    }
    
    @discardableResult func updateVisitCount(_ completion: ((TubeUserInfo?) -> Void)?) {
        let callback = completion ?? {(_) in }
        
        DispatchQueue.global().async {
            self.user { (info) in
                if let data = info {
                    let param = [
                        "id": data.id,
                        "token": self.deviceToken() ?? ""
                    ]
                    
                    NetService.shared.get(path: "/svc/api/user/update/visitcnt", parameters: param).responseString(completionHandler: { (res) in
                        if let messaage = res.result.value {
                            print(messaage)
                        }
                        
                        callback(info)
                    })
                } else {
                    callback(info)
                }
            }
        }
    }
    
    func isOn() -> Bool {
        return naverConnection.accessToken != nil
    }
    
    func tryLogin(_ viewController: UIViewController, completion: ((TubeUserInfo?) -> Void)?) {
        self.viewController = viewController
        self.completionHandler = completion
        
        naverConnection.requestThirdPartyLogin()
    }
    
    func logout(completion: (() -> Void)?) {
        if let token = naverConnection.accessToken {
            naverUser(token, user: nil)
            tubeUser(token, user: nil)
        }
        
        naverConnection.resetToken()
        
        if let handler = completion {
            handler()
        }
    }
    
    private func naverUserKey(_ accessToken: String) -> String {
        return "naver_user_\(accessToken)"
    }
    
    private func tubeUserKey(_ accessToken: String) -> String {
        return "tube_user_\(accessToken)"
    }
    
    func naverUser(_ accessToken: String) -> User? {
        return naverUserMap[naverUserKey(accessToken)]
    }
    
    func tubeUser(_ accessToken: String) -> TubeUserInfo? {
        return tubeUserMap[tubeUserKey(accessToken)]
    }
    
    func naverUser(_ accessToken: String, user: User?) {
        naverUserMap[accessToken] = user
    }
    
    func tubeUser(_ accessToken: String, user: TubeUserInfo?) {
        tubeUserMap[accessToken] = user
    }
    
    func accessToken() -> String? {
        return naverConnection.accessToken
    }
    
    func userId(completion: ((String) -> Void)?) {
        let callback = completion ?? {(_) in }
        
        user { (opt) in
            callback(opt?.id ?? Global.guestId)
        }
    }
    
    func user(_ completion: ((TubeUserInfo?) -> Void)?) {
        userInfo(retry: 2, completion: completion)
    }
    
    private func userInfo(retry: Int, completion: ((TubeUserInfo?) -> Void)?) {
        let callback = completion ?? {(_) in }
        
        if retry > 0, let token = naverConnection.accessToken {
            if let info = tubeUser(token) {
                callback(info)
            } else {
                NetService.shared.get("https://apis.naver.com/nidlogin/nid/getUserProfile.xml",
                                      parameters: nil,
                                      headers: ["Authorization": "Bearer \(token)"]).response(completionHandler: { (res) in
                                        if let data = res.data, let user = User(data: data), user.id != Global.guestId {
                                            self.naverUser(token, user: user)
                                            
                                            self.tubeUser(user.id, completion: { (tubeUser) in
                                                if let userInfo = tubeUser {
                                                    callback(userInfo)
                                                } else {
                                                    self.joinUser(user: user, completion: { (success) in
                                                        if success {
                                                            self.tubeUser(user.id, completion: completion)
                                                        } else {
                                                            callback(nil)
                                                        }
                                                    })
                                                }
                                            })
                                        } else {
                                            self.refreshToken()
                                            self.userInfo(retry: retry - 1, completion: completion)
                                        }
                                      })
            }
        } else {
            logout(completion: nil)
            callback(nil)
        }
    }
    
    private func joinUser(user: User, completion: ((Bool) -> Void)?) {
        if user.id.isEmpty {
            if let callback = completion {
                callback(false)
            }
        } else {
            let path = "/svc/api/user/join"
            var parameters: [String: Any] = ["id": user.id, "os": "I"]
            
            if let age = user.age {
                do {
                    let regex = try NSRegularExpression(pattern: "[^-d]*", options: .caseInsensitive)
                    let range = NSRange(location: 0, length: age.characters.count)
                    
                    if let match = regex.firstMatch(in: age, options: [], range: range) {
                        parameters["age"] = (age as NSString).substring(with: match.range)
                    }
                } catch let e {
                    print("\(e)")
                }
            }
            
            if let gender = user.gender {
                parameters["gender"] = gender
            }
            
            
            if let nickname = user.nickname {
                parameters["nickname"] = nickname
            }
            
            if let image = user.profileImage {
                parameters["image"] = image
            }
            
            if let token = deviceToken() {
                parameters["token"] = token
            }
            
            NetService.shared.post(path: path, parameters: parameters).responseString(completionHandler: { (res) in
                if let callback = completion {
                    callback(res.result.value != nil)
                }
            })
        }
    }
    
    private func tubeUser(_ id: String, completion: ((TubeUserInfo?) -> Void)?) {
        let callback = completion ?? {(_) in }
        
        NetService.shared.getObject(path: "/svc/api/user/info?id=\(id)", completionHandler: { (res: DataResponse<TubeUserInfo>) in

            if let userInfo = res.result.value {
                if let token = self.naverConnection.accessToken {
                    self.tubeUser(token, user: userInfo)
                }
                
                callback(userInfo)
            } else {
                callback(nil)
            }
        })
    }
    
    func prepare(_ viewController: UIViewController, for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showPurchase":
                if let nav = segue.destination as? UINavigationController,
                    let top = nav.topViewController as? PurchaseController {
                    
                    top.controller = viewController
                }
            default:
                print("others")
            }
        }
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
        case "showPurchase":
            if AuthenticateService.shared.isOn() {
                return true
            } else {
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
            }
            
        default:
            return true
        }
    }
    
    private func isActiveUser() throws -> Bool {
        if let token = naverConnection.accessToken, let tubeUser = tubeUser(token) {
            if tubeUser.isActiveUser {
                return true
            } else {
                throw AuthError.unauthorized
            }
        } else {
            throw AuthError.needToLogin
        }
    }
    
    func processAccessToken(url: URL) -> Bool {
        print("0 ============== \(url)")
        
        if url.scheme ?? "" == "speakingtube" {
            if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true), let queryItems = urlComponents.queryItems {
                print(queryItems)
                print("\(naverConnection.accessToken)")
            }
            
            return true
        } else {
            return false
        }
    }
    
    func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {
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
