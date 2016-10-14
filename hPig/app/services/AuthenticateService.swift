//
//  AuthenticateService.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 29..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import SWXMLHash

class AuthenticateService: NSObject, NaverThirdPartyLoginConnectionDelegate {
    static let shared: AuthenticateService = {
        let instance = AuthenticateService()
        return instance
    }()
    
    private let naverConnection: NaverThirdPartyLoginConnection = NaverThirdPartyLoginConnection.getSharedInstance()!
    private weak var viewController: UIViewController? = nil
    private var completionHandler: ((_ isSuccess: Bool) -> Void)? = nil
    private var userMap = [String: User]()
    
    func prepare() {
        naverConnection.serviceUrlScheme = kServiceAppUrlScheme
        naverConnection.consumerKey = kConsumerKey
        naverConnection.consumerSecret = kConsumerSecret
        naverConnection.appName = kServiceAppName
        
        naverConnection.isNaverAppOauthEnable = true
        naverConnection.isInAppOauthEnable = true
        naverConnection.delegate = self
    }
    
    func isOn() -> Bool {
        return naverConnection.accessToken != nil
    }
    
    func userId(completion: @escaping (String) -> Void) {
        user { (opt) in
            if let item = opt {
                completion(item.id)
            } else {
                completion(Global.guestId)
            }
        }
    }
    
    func tryLogin(viewController: UIViewController, completion: ((_ isSuccess: Bool) -> Void)?) {
        self.viewController = viewController
        self.completionHandler = completion
        
        naverConnection.requestThirdPartyLogin()
    }
    
    func logout(completion: (() -> Void)?) {
        naverConnection.resetToken()
        
        if let handler = completion {
            handler()
        }
    }
    
    func user(_ completion: @escaping (User?) -> Void) {
        if let token = naverConnection.accessToken {
            if let user = userMap[token] {
                completion(user)
            } else {
                var req = URLRequest(url: URL(string: "https://apis.naver.com/nidlogin/nid/getUserProfile.xml")!)
                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                NetService.shared.get(req: req).response { (res) in
                    if let data = res.data {
                        let user = User(data: data)
                        self.userMap[token] = user
                        completion(user)
                    } else {
                        completion(nil)
                    }
                }
            }
        } else {
            completion(nil)
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
