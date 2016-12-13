//
//  LoginProtocol.swift
//  hPig
//
//  Created by Jesse on 2016. 12. 11..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

enum AuthError: Error {
    case needToLogin
    case unauthorized
}

enum hLoginResult: Int {
    case success = 0
    case parameterNotSet = 1
    case cancelByUser = 2
    case naverAppNotInstalled = 3
    case naverAppVersionInvalid = 4
    case oauthMethodNotSet = 5
    case InvalidRequest = 6
    case clientNetworkProblem = 7
    case unauthorizedClient = 8
    case unsupportedResponseType = 9
    case networkError = 10
    case unkownError = 11
}

protocol LoginProtocol {
    func isOn() -> Bool
    
    func currentUser() -> User?
    
    func tryLogin(from viewController: UIViewController?, completion: ((User?) -> Void)?)
    
    func logout(_ completion: (() -> Void)?)
    
    func process(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool
}
