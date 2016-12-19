//
//  SpeakingTubeLogin.swift
//  hPig
//
//  Created by Jesse on 2016. 12. 16..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

class SpeakingTubeLogin: LoginProtocol {
    
    private var latestUser: User? = nil
    
    var loginType: LoginType = .email
    
    var completion: ((User?) -> Void)? = nil
    
    init() {
        NotificationCenter.default.addObserver(forName: kSuccessLoginCompletion, object: nil, queue: nil, using: { (notif) in
            let callback = self.completion ?? {(_)in}
            
            if let user = notif.object as? User {
                self.latestUser = user
                callback(user)
            } else {
                callback(nil)
            }
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func isOn() -> Bool {
        return latestUser != nil
    }
    
    func currentUser() -> User? {
        return latestUser
    }
    
    func tryLogin(from viewController: UIViewController?, completion: ((User?) -> Void)?) {
        self.completion = completion
        
        if let navigator = UIStoryboard(name: "SpeakingTubeRegister", bundle: Bundle.main).instantiateInitialViewController() {
            viewController?.present(navigator, animated: true, completion: nil)
        } else {
            if let callback = completion {
                callback(nil)
            }
        }
    }
    
    func logout(_ completion: (() -> Void)?) {
        self.latestUser = nil
    }
    
    func process(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return true
    }
}
