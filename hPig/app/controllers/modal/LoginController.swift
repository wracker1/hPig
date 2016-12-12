//
//  LoginController.swift
//  hPig
//
//  Created by Jesse on 2016. 12. 10..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "로그인"
    }
    
    @IBAction func tryNaverLogin(_ sender: Any) {
        LoginService.shared.login(.naver, loginController: self)
    }
    
    @IBAction func tryKakaoLogin(_ sender: Any) {
        LoginService.shared.login(.kakaoTalk, loginController: self)
    }
    
    @IBAction func tryFacebookLogin(_ sender: Any) {
        LoginService.shared.login(.facebook, loginController: self)
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
