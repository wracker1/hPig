//
//  KakaoLogin.swift
//  hPig
//
//  Created by Jesse on 2016. 12. 12..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

class KakaoLogin: LoginProtocol {
    private var userMap = [String: User]()
    private weak var viewController: UIViewController? = nil
    
    private func errorCode(_ e: Error?) -> KOErrorCode? {
        if let error = e as? NSError {
            return KOErrorCode(Int32(error.code))
        } else {
            return nil
        }
    }
    
    private func session() -> KOSession? {
        if let session = KOSession.shared() {
            session.isAutomaticPeriodicRefresh = true
            return session
        } else {
            return nil
        }
    }
    
    private func sessionOpen(completion: ((Error?) -> Void)?) {
        let callback = completion ?? {(_) in}
        
        session()?.open(completionHandler: { (e) in
            if let code = self.errorCode(e), code == KOErrorAlreadyLoginedUser {
                callback(nil)
            } else if e == nil {
                callback(nil)
            } else {
                callback(e)
            }
        })
    }
    
    private func requestPermission(completion: ((Error?) -> Void)?) {
        let callback = completion ?? {(_) in}
        
        sessionOpen { (e) in
            if e == nil {
                KOSessionTask.signupTask(withProperties: [:], completionHandler: { (success, e) in
                    if let code = self.errorCode(e), code == KOServerErrorAlreadySignedUpUser  {
                        callback(nil)
                    } else if e == nil {
                        callback(nil)
                    } else {
                        callback(e)
                    }
                })
            } else if let code = self.errorCode(e), code != KOErrorCancelled {
                self.viewController?.view.presentToast(e.debugDescription)
            } else {
                callback(e)
            }
        }
    }
    
    private func accessToken() -> String? {
        if let session = KOSession.shared(), let token = session.accessToken {
            return token
        } else {
            return nil
        }
    }
    
    func isOn() -> Bool {
        return currentUser() != nil
    }
    
    func currentUser() -> User? {
        if let token = accessToken(), let user = userMap[token] {
            return user
        } else {
            return nil
        }
    }
    
    func tryLogin(from viewController: UIViewController?, completion: ((User?) -> Void)?) {
        self.viewController = viewController
        
        let callback = completion ?? {(_) in}
        
        if let user = currentUser() {
            callback(user)
        } else {
            requestPermission { (e) in
                if e == nil {
                    KOSessionTask.meTask(completionHandler: { (res, e) in
                        if let token = self.accessToken(), let kakaoUser = res as? KOUser, let user = User(kakaoUser) {
                            self.userMap[token] = user
                            
                            if let callback = completion {
                                callback(user)
                            }
                        }
                    })
                } else {
                    callback(nil)
                }
            }
        }
    }
    
    func logout(_ completion: (() -> Void)?) {
        userMap.removeAll()
        
        session()?.logoutAndClose { (success, e) in
            if let error = e, let vc = self.viewController {
                vc.view.presentToast(error.localizedDescription)
            }
            
            if let callback = completion {
                callback()
            }
        }
    }
    
    func process(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        } else {
            return true
        }
    }
    
    
}
