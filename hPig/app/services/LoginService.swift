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
    
    private func userFromUserDefault() -> User? {
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
    
    private func tubeuserFromUserDefault(_ user: User) -> TubeUserInfo? {
        let id = user.id
        
        if loginManager == nil {
            switch user.loginType {
            case .naver:
                self.loginManager = naverLoginManager()
                
            case .facebook:
                self.loginManager = facebookLoginManager()
                
            case .kakaoTalk:
                break
            }
        }
        
        return tubeUserMap[id]
    }
    
    func tryLogin(_ viewController: UIViewController, completion: ((TubeUserInfo?) -> Void)?) {
        if let current = userFromUserDefault() {
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
        
        switch type {
        
        case .naver:
            self.loginManager = naverLoginManager()
            
        case .facebook:
            self.loginManager = facebookLoginManager()
            
        case .kakaoTalk:
            break
        
        }
    }
    
    private func loginHandler() -> ((User?) -> Void) {
        let callback = { (res: TubeUserInfo?) in
            if let listener = self.completion {
                listener(res)
            }
            
            if res != nil, let vc = self.viewController {
                vc.dismiss(animated: true, completion: nil)
            }
        }
        
        return { (res: User?) in
            if let user = res {
                self.tubeUserInfo(from: user, completion: callback)
            }
        }
    }
    
    private func naverLoginManager() -> LoginProtocol {
        let manager = NaverLogin()
        manager.loginController = loginController
        manager.tryLogin(loginHandler())
        return manager
    }
    
    private func facebookLoginManager() -> LoginProtocol {
        let manager = FacebookLogin()
        manager.loginController = loginController
        manager.tryLogin(loginHandler())
        return manager
    }
    
    
    // tube
    
    private func tubeUserInfo(from user: User, completion: ((TubeUserInfo?) -> Void)?) {
        let callback = completion ?? {(_) in }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(data, forKey: latestUserKey)
        UserDefaults.standard.synchronize()
        
        ApiService.shared.updateUser(user)
        
        tubeUserInfoFromServer(user.id, loginType: user.loginType, completion: { (tubeUser) in
            if let userInfo = tubeUser {
                callback(userInfo)
            } else {
                AuthenticateService.shared.joinUser(user: user, completion: { (success) in
                    if success {
                        self.tubeUserInfoFromServer(user.id, loginType: user.loginType, completion: completion)
                    } else {
                        callback(nil)
                    }
                })
            }
        })
    }
    
    func tubeUserInfoFromServer(_ id: String, loginType: LoginType, completion: ((TubeUserInfo?) -> Void)?) {
        ApiService.shared.speakingTubeUserInfo(id, loginType: loginType, completion: { (res) in
            if let user = res {
                self.tubeUserMap[user.id] = user
            }
            
            if let callback = completion {
                callback(res)
            }
        })
    }
    
    func user(_ completion: ((TubeUserInfo?, User?) -> Void)?) {
        let callback = completion ?? {(_) in }
        
        if let cached = userFromUserDefault() ?? userFromLoginManager() {
            tubeUserInfo(from: cached, completion: { (res) in
                callback(res, cached)
            })
        } else {
            callback(nil, nil)
        }
    }
    
    func userId(completion: ((String) -> Void)?) {
        let callback = completion ?? {(_) in }
        
        user { (res, _) in
            callback(res?.id ?? kGuestId)
        }
    }
    
    func isActiveUser() throws -> Bool {
        if let cached = userFromUserDefault() ?? userFromLoginManager(),
            let user = tubeuserFromUserDefault(cached) {
            
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
        if let cached = userFromUserDefault() ?? userFromLoginManager() {
            return tubeuserFromUserDefault(cached) != nil
        } else {
            return false
        }
    }
    
    func process(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return loginManager?.process(app, open: url, options: options) ?? false
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
