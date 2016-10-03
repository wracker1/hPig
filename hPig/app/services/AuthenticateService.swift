//
//  AuthenticateService.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 29..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

class AuthenticateService: NSObject, NaverThirdPartyLoginConnectionDelegate {
    static let shared: AuthenticateService = {
        let instance = AuthenticateService()
        return instance
    }()
    
    private let naverConnection: NaverThirdPartyLoginConnection = NaverThirdPartyLoginConnection.getSharedInstance()!
    private weak var viewController: UIViewController? = nil
    private var completionHandler: ((_ isSuccess: Bool) -> Void)? = nil
    
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
    
    func userId() -> String {
        return "guest"
    }
    
    func tryLogin(viewController: UIViewController, completion: ((_ isSuccess: Bool) -> Void)?) {
        self.viewController = viewController
        self.completionHandler = completion
        
        naverConnection.requestThirdPartyLogin()
    }
    
    func logout(_ completion: (() -> Void)?) {
        naverConnection.resetToken()
        
        if let handler = completion {
            handler()
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
