//
//  NaverLogin.swift
//  hPig
//
//  Created by Jesse on 2016. 12. 11..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

class NaverLogin: NSObject, LoginProtocol, NaverThirdPartyLoginConnectionDelegate {
    
    private lazy var naverConnection: NaverThirdPartyLoginConnection = NaverThirdPartyLoginConnection.getSharedInstance()!
    
    private var userMap = [String: User]()
    private var completion: ((User?) -> Void)? = nil
    private weak var viewController: UIViewController? = nil
    
    override init() {
        super.init()
        
        self.naverConnection.serviceUrlScheme = kServiceAppUrlScheme
        self.naverConnection.consumerKey = kConsumerKey
        self.naverConnection.consumerSecret = kConsumerSecret
        self.naverConnection.appName = kServiceAppName
        
        self.naverConnection.isNaverAppOauthEnable = true
        self.naverConnection.isInAppOauthEnable = true
        self.naverConnection.delegate = self
    }
    
    // login protocol
    
    var loginType: LoginType = .naver
    
    func isOn() -> Bool {
        return currentUser() != nil
    }
    
    func tryLogin(from viewController: UIViewController?, completion: ((User?) -> Void)?) {
        self.viewController = viewController
        self.completion = completion
        naverConnection.requestThirdPartyLogin()
    }
    
    func logout(_ completion: (() -> Void)?) {
        userMap.removeAll()
        
        naverConnection.resetToken()
        
        if let callback = completion {
            callback()
        }
    }
    
    func currentUser() -> User? {
        if let token = naverConnection.accessToken {
            return userMap[token]
        } else {
            return nil
        }
    }
    
    func process(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let result = Int(naverConnection.receiveAccessToken(url).rawValue)
        
        if let loginResult = hLoginResult(rawValue: result) {
            switch loginResult {
            case .success:
                user(completion)
                
            case .cancelByUser:
                break
                
            default:
                print("\(loginResult)")
            }
        }
        
        return true
    }
    
    func user(_ completion: ((User?) -> Void)?) {
        userInfo(retry: 2, completion: completion)
    }
    
    private func userInfo(retry: Int, completion: ((User?) -> Void)?) {
        let callback = completion ?? {(_) in }
        
        if retry > 0, let token = naverConnection.accessToken {
            if let cached = userMap[token] {
                callback(cached)
            } else {
                ApiService.shared.naverUserInfo(accessToken: token, completion: { (res) in
                    if let data = res, let user = User(data: data, loginType: .naver), user.id != kGuestId {
                        self.userMap[token] = user
                        callback(user)
                    } else {
                        self.naverConnection.requestAccessTokenWithRefreshToken()
                        self.userInfo(retry: retry - 1, completion: completion)
                    }
                })
            }
        } else {
            logout(nil)
            callback(nil)
        }
    }
    
    // naver delegate
    
    func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {
        if let vc = viewController, let naverLoginController = NLoginThirdPartyOAuth20InAppBrowserViewController(request: request) {
            
            let navigator = UINavigationController(rootViewController: naverLoginController)
            vc.present(navigator, animated: true, completion: nil)
        }
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        user(completion)
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        user(completion)
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        print("2 ==============")
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("3 ============== \(oauthConnection), \(error)")
    }

}
