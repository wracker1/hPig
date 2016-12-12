//
//  FacebookLogin.swift
//  hPig
//
//  Created by Jesse on 2016. 12. 12..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

class FacebookLogin: LoginProtocol {
    private lazy var fbLoginManager = FBSDKLoginManager()
    
    private var userMap = [String: User]()
    
    weak var _loginController: UIViewController? = nil
    
    private func requestReadPermission(completion: ((FBSDKLoginManagerLoginResult?, Error?) -> Void)?) {
        if let vc = loginController {
            fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: vc, handler: { (res, e) in
                FBSDKProfile.enableUpdates(onAccessTokenChange: true)
                
                if let callback = completion {
                    callback(res, e)
                }
            })
        } else {
            if let callback = completion {
                callback(nil, nil)
            }
        }
    }
    
    private func userId() -> String? {
        if let token = FBSDKAccessToken.current(), let id = token.userID {
            return id
        } else {
            return nil
        }
    }
    
    private func requestMyInfo(_ completion: ((User?) -> Void)?) {
        let callback = completion ?? {(_) in}
        
        if let req = FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id,name,picture,gender,birthday,email,age_range"]) {
            req.start(completionHandler: { (conn, data, reqError) in
                if reqError == nil,
                    let json = data as? [String: Any],
                    let user = User(data: json, loginType: .facebook),
                    let id = self.userId() {
                    
                    self.userMap[id] = user
                    callback(user)
                } else if let nserror = reqError as? NSError {
                    if nserror.code != 8 {
                        self.loginController?.view.presentToast(reqError.debugDescription)
                    } else {
                        callback(nil)
                    }
                } else {
                    callback(nil)
                }
            })
        }
    }
    
    var loginController: UIViewController? {
        get { return _loginController }
        set { _loginController = newValue }
    }
    
    func isOn() -> Bool {
        return FBSDKAccessToken.current() != nil
    }
    
    func currentUser() -> User? {
        if let id = userId() {
            return userMap[id]
        } else {
            return nil
        }
    }
    
    func tryLogin(_ completion: ((User?) -> Void)?) {
        let callback = completion ?? {(_) in}
        
        if isOn() {
            callback(currentUser())
        } else {
            requestReadPermission(completion: { (res, permError) in
                if permError == nil, let req = FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id,name,picture,gender,birthday,email,age_range"]) {
                    req.start(completionHandler: { (conn, data, reqError) in
                        if reqError == nil,
                            let json = data as? [String: Any],
                            let user = User(data: json, loginType: .facebook),
                            let id = self.userId() {
                            
                            self.userMap[id] = user
                            callback(user)
                        } else if let nserror = reqError as? NSError {
                            if nserror.code != 8 {
                                self.loginController?.view.presentToast(reqError.debugDescription)
                            } else {
                                callback(nil)
                            }
                        } else {
                            callback(nil)
                        }
                    })
                } else {
                    self.loginController?.view.presentToast(permError.debugDescription)
                    callback(nil)
                }
            })
        }
    }
    
    func logout(_ completion: (() -> Void)?) {
        userMap.removeAll()
        fbLoginManager.logOut()
    }
    
    func process(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app,
                                                                     open: url,
                                                                     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!,
                                                                     annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
}
