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
    case email = "email"
}

class LoginService {
    static let shared: LoginService = {
        return LoginService()
    }()
    
    private weak var viewController: UIViewController? = nil
    private var completion: ((TubeUserInfo?) -> Void)? = nil
    private var loginManager: LoginProtocol? = nil
    private var tubeUserMap = [String : TubeUserInfo]()
    private let latestUserKey = "latestUser"
    
    init() {
        NotificationCenter.default.addObserver(forName: kRegisterCompletion, object: nil, queue: nil, using: { (notif) in
            if let from = self.viewController, let user = notif.object as? User {
                from.view.presentToast("회원가입이 완료되었습니다.")
                
                self.createUserInfoUserDefault(user: user)
                self.tubeUserInfoFromServer(user.id, loginType: user.loginType, completion: self.completion)
            }
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loginType() -> LoginType? {
        return loginManager?.loginType
    }
    
    private func createUserInfoUserDefault(user: User) {
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(data, forKey: latestUserKey)
        UserDefaults.standard.synchronize()
    }
    
    private func userFromUserDefault() -> User? {
        if let archived = UserDefaults.standard.object(forKey: latestUserKey) as? Data,
            let current = NSKeyedUnarchiver.unarchiveObject(with: archived) as? User {
            
            return current
        } else {
            return nil
        }
    }
    
    private func removeUserInfoFromCache(id: String) {
        UserDefaults.standard.removeObject(forKey: id)
        UserDefaults.standard.synchronize()
        
        tubeUserMap.removeAll()
    }
    
    private func userFromLoginManager() -> User? {
        if let manager = loginManager, let current = manager.currentUser() {
            return current
        } else {
            return nil
        }
    }
    
    private func tubeuserFromMemCache(_ user: User) -> TubeUserInfo? {
        let id = user.id
        self.loginManager = self.loginProtocol(user.loginType)
        return tubeUserMap[id]
    }
    
    func tryLogin(_ viewController: UIViewController, sourceView: UIView?, completion: ((TubeUserInfo?) -> Void)?) {
        if let current = userFromUserDefault() {
            tubeUserInfo(from: current, completion: completion)
        } else {
            self.viewController = viewController
            self.completion = completion
            
            let loginView = LoginView(frame: CGRectZero)
            let width = min(viewController.view.bounds.size.width, kMaxPopoverViewWidth)
            let alert = AlertService.shared.actionSheet(loginView, width: width)
            
            if let target = sourceView {
                alert.popoverPresentationController?.sourceView = target
                alert.popoverPresentationController?.sourceRect = target.bounds
            }
            
            viewController.present(alert, animated: true, completion: nil)
            
            loginView.facebookButton.addTarget(self, action: #selector(self.loginByFacebook), for: .touchUpInside)
            loginView.kakaoButton.addTarget(self, action: #selector(self.loginByKakao), for: .touchUpInside)
            loginView.naverButton.addTarget(self, action: #selector(self.loginByNaver), for: .touchUpInside)
            loginView.tubeButton.addTarget(self, action: #selector(self.loginByTube), for: .touchUpInside)
            loginView.closeButton.addTarget(self, action: #selector(self.dismissLoginView), for: .touchUpInside)
        }
    }
    
    @objc func dismissLoginView() {
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func loginByNaver() {
        login(.naver)
    }
    
    @objc func loginByFacebook() {
        login(.facebook)
    }
    
    @objc func loginByKakao() {
        login(.kakaoTalk)
    }
    
    @objc func loginByTube() {
        login(.email)
    }
    
    func login(_ type: LoginType) {
        if let controller = viewController {
            controller.dismiss(animated: false, completion: {
                self.loginManager = self.loginProtocol(type)
                self.loginManager?.tryLogin(from: controller, completion: self.loginHandler(controller))
            })
        }
    }
    
    private func loginProtocol(_ type: LoginType) -> LoginProtocol {
        switch type {
        case .naver:
            return NaverLogin()
            
        case .facebook:
            return FacebookLogin()
            
        case .kakaoTalk:
            return KakaoLogin()
            
        case .email:
            return SpeakingTubeLogin()
        }
    }
    
    private func tubeUserInfoRegisterHandler(_ fromViewController: UIViewController?, user: User) {
        if let type = self.loginType(),
            let navigator = UIStoryboard(name: "Register", bundle: Bundle.main).instantiateInitialViewController() as? UINavigationController,
            let registerController = navigator.topViewController as? RegisterController {
            registerController.user = user
            registerController.isSocialLogin = type != .email
            
            fromViewController?.present(navigator, animated: true, completion: nil)
        }
    }
    
    private func loginHandler(_ fromViewController: UIViewController?) -> ((User?) -> Void) {
        let callback = completion ?? {(_)in}
        
        return { (res: User?) in
            if let user = res {
                self.tubeUserInfo(from: user, completion: { (info) in
                    if info == nil {
                        self.tubeUserInfoRegisterHandler(fromViewController, user: user)
                    } else {
                        callback(info)
                    }
                })
            } else {
                callback(nil)
            }
        }
    }

    
    // tube
    
    private func tubeUserInfo(from user: User, completion: ((TubeUserInfo?) -> Void)?) {
        let callback = completion ?? {(_) in }

        createUserInfoUserDefault(user: user)
        
        if let tubeUser = tubeuserFromMemCache(user) {
            callback(tubeUser)
        } else {
            tubeUserInfoFromServer(user.id, loginType: user.loginType, completion: { (tubeUser) in
                if let userInfo = tubeUser {
                    ApiService.shared.updateUser(user)
                    
                    callback(userInfo)
                } else {
                    callback(nil)
                }
            })
        }
    }
    
    func tubeUserInfoFromServer(_ id: String, loginType: LoginType, completion: ((TubeUserInfo?) -> Void)?) {
        ApiService.shared.speakingTubeUserInfo(id, loginType: loginType, completion: { (res) in
            if let user = res {
                self.tubeUserMap[user.id] = user
            } else {
                self.logout(completion: nil)
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
            let user = tubeuserFromMemCache(cached) {
            
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
            return tubeuserFromMemCache(cached) != nil
        } else {
            return false
        }
    }
    
    func process(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return loginManager?.process(app, open: url, options: options) ?? false
    }
    
    func logout(completion: (() -> Void)?) {
        removeUserInfoFromCache(id: latestUserKey)
        loginManager?.logout(nil)
        
        if let callback = completion {
            callback()
        }
    }

   }
