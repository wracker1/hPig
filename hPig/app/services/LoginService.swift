//
//  LoginService.swift
//  hPig
//
//  Created by Jesse on 2016. 12. 10..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import SWXMLHash
import Social
import Accounts

enum LoginType: String {
    case naver = "naver"
    case iCloud = "icloud"
    case kakaoTalk = "kakaoTalk"
    case facebook = "facebook"
}

class LoginService {
    static let shared: LoginService = {
        return LoginService()
    }()
    
    private weak var viewController: UIViewController? = nil
    private weak var loginController: LoginController? = nil
    
    private var loginManager: LoginProtocol? = nil
    private var completion: ((TubeUserInfo?) -> Void)? = nil
    private var tubeUserMap = [String : TubeUserInfo]()
    
    private let latestUserKey = "latestUser"
    
//    private var loginType: LoginType? = nil

//    private lazy var fbLoginManager = FBSDKLoginManager()

//    private var tubeUserMap = [String: TubeUserInfo]()
    
    init() {
        
    }
    
    private func userFromCache() -> User? {
        if let archived = UserDefaults.standard.object(forKey: latestUserKey) as? Data,
            let current = NSKeyedUnarchiver.unarchiveObject(with: archived) as? User {
            
            return current
        } else {
            return nil
        }
    }
    
    private func userFromLoginManager() -> User? {
        if let manager = loginManager, let current = manager.currentUser() {
            return current
        } else {
            return nil
        }
    }
    
    func tryLogin(_ viewController: UIViewController, completion: ((TubeUserInfo?) -> Void)?) {
        if let current = userFromCache() {
            tubeUserInfo(from: current, completion: completion)
        } else {
            if let navigator = UIStoryboard(name: "Login", bundle: Bundle.main).instantiateInitialViewController() {
                self.viewController = viewController
                self.completion = completion
                
                viewController.present(navigator, animated: true, completion: nil)
            }
        }
    }
    
    func login(_ type: LoginType, loginController: LoginController) {
        self.loginController = loginController
        
        let callback = { (res: TubeUserInfo?) in
            if let listener = self.completion {
                listener(res)
            }
            
            if res != nil, let vc = self.viewController {
                vc.dismiss(animated: true, completion: nil)
            }
        }
        
        switch type {
        
        case .naver:
            let manager = NaverLogin()
            manager.loginController = loginController
            manager.tryLogin({ (res) in
                if let user = res {
                    self.tubeUserInfo(from: user, completion: callback)
                }
            })
            
            self.loginManager = manager
            
        case .iCloud:
            break
            
        case .kakaoTalk:
            break
            
        case .facebook:
            break
        }
    }
    
    private func tryNaverLogin() {
        
    }
    
    private func tryiCloudLogin() {

    }
    
    private func tryKakaotalkLogin() {
        
    }
    
    private func tryFacebookLogin() {
//        if let vc = loginController {
//            fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: vc, handler: { (res, e) in
//                FBSDKProfile.enableUpdates(onAccessTokenChange: true)
//                
//                if let result = res, !result.isCancelled, let req = FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id,name,picture,gender,first_name,last_name,birthday,email"]) {
//                    req.start(completionHandler: { (conn, data, e) in
//                        print(data)
//                    })
//                } else if let error = e {
//                    vc.view.presentToast(error.localizedDescription)
//                }
//            })
//        }
    }
    
    // tube
    
    private func tubeUserInfo(from user: User, completion: ((TubeUserInfo?) -> Void)?) {
        let callback = completion ?? {(_) in }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(data, forKey: latestUserKey)
        UserDefaults.standard.synchronize()
        
        tubeUserInfoFromServer(user.id, completion: { (tubeUser) in
            if let userInfo = tubeUser {
                callback(userInfo)
            } else {
                AuthenticateService.shared.joinUser(user: user, completion: { (success) in
                    if success {
                        self.tubeUserInfoFromServer(user.id, completion: completion)
                    } else {
                        callback(nil)
                    }
                })
            }
        })
    }
    
    func tubeUserInfoFromServer(_ id: String, completion: ((TubeUserInfo?) -> Void)?) {
        ApiService.shared.speakingTubeUserInfo(id, completion: { (res) in
            if let user = res {
                self.tubeUserMap[id] = user
            }
            
            if let callback = completion {
                callback(res)
            }
        })
    }
    
    func user(_ completion: ((TubeUserInfo?) -> Void)?) {
        let callback = completion ?? {(_) in }
        
        if let cached = userFromCache() ?? userFromLoginManager() {
            tubeUserInfo(from: cached, completion: { (res) in
                callback(res)
            })
        } else {
            callback(nil)
        }
    }
    
    func userId(completion: ((String) -> Void)?) {
        let callback = completion ?? {(_) in }
        
        user { (res) in
            callback(res?.id ?? kGuestId)
        }
    }
    
    func isActiveUser() throws -> Bool {
        if let cached = userFromCache() ?? userFromLoginManager(), let user = tubeUserMap[cached.id] {
            if user.isActiveUser {
                return true
            } else {
                throw AuthError.unauthorized
            }
        } else {
            throw AuthError.needToLogin
        }
    }
    
    func isOn() -> Bool {
        if let cached = userFromCache() ?? userFromLoginManager() {
            return tubeUserMap[cached.id] != nil
        } else {
            return false
        }
    }
    
    func proccess(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return loginManager?.proccess(app, open: url, options: options) ?? false
    }
    
    func logout(completion: (() -> Void)?) {
        UserDefaults.standard.removeObject(forKey: latestUserKey)
        UserDefaults.standard.synchronize()
        
        tubeUserMap.removeAll()
        loginManager?.logout(nil)
        
        if let callback = completion {
            callback()
        }
    }

   }
