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
    
    func prepare() {
        naverConnection.appName = kServiceAppName
        naverConnection.serviceUrlScheme = kServiceAppUrlScheme
        naverConnection.consumerKey = kConsumerKey
        naverConnection.consumerSecret = kConsumerSecret
        
        naverConnection.isNaverAppOauthEnable = true
        naverConnection.isInAppOauthEnable = true
        naverConnection.delegate = self
        
        naverConnection.requestAccessTokenWithRefreshToken()
    }
    
    func processAccessToken(url: URL) -> Bool {
        if url.scheme ?? "" == "speakingtube" {
            let result = naverConnection.receiveAccessToken(url)
            
            print(result)
            
            return true
        } else {
            return false
        }
    }
    
    func tryLogin() {
        naverConnection.requestThirdPartyLogin()
    }
    
    func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {
        print("1 ============== \(request)")
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("2 ==============")
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
