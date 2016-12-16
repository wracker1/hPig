//
//  AuthCodeLoginController.swift
//  hPig
//
//  Created by Jesse on 2016. 12. 16..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class AuthCodeLoginController: UIViewController {

    var email: String? = nil
    
    @IBOutlet weak var authCodeField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "인증코드 입력"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let authencatedEmail = email {
            ApiService.shared.requestAuthenticatedCode(authencatedEmail, loginType: .email, completion: { (res) in
                
                switch res {
                case "SUCCESS":
                    self.view.presentToast("이메일을 발송하였습니다. 확인 후 인증코드를 입력해주세요.")
                    
                case "NO_USER":
                    self.view.presentToast("존재하지 않는 이메일입니다.")
                               
                default:
                    self.view.presentToast("문제가 생겨 메일발송에 실패하였습니다. 잠시 후 다시 시도해보세요.")
                }
            })
        }
    }

    @IBAction func checkAuthCode(_ sender: Any) {
        if let authencatedEmail = email,
            let authCode = authCodeField.text, !authCode.isEmpty {
            
            ApiService.shared.checkAuthenticatedCode(authencatedEmail, loginType: .email, authCode: authCode, completion: { (res) in
                switch res {
                case .success:
                    NotificationCenter.default.post(name: kSuccessLoginCompletion, object: ["id": authencatedEmail, "email": authencatedEmail], userInfo: nil)
                    self.dismiss(animated: true, completion: nil)
                case .fail:
                    self.view.presentToast("인증코드가 맞지 않습니다.")
                }
            })
        }
    }
}
