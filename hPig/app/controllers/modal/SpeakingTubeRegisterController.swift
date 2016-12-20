//
//  SpeakingTubeRegisterViewController.swift
//  hPig
//
//  Created by Jesse on 2016. 12. 16..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreGraphics

class SpeakingTubeRegisterController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerButton.cornerRadiusly()
        
        loginButton.border()
        loginButton.cornerRadiusly()
        
        let inputAccessoryView = BasicInputAccessory(frame: self.view.bounds)
        inputAccessoryView.closeButton.addTarget(self, action: #selector(self.resignEmailField), for: .touchUpInside)
        emailField.inputAccessoryView = inputAccessoryView
    }
    
    func resignEmailField() {
        emailField.resignFirstResponder()
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func register(_ sender: Any) {
        if let navigator = UIStoryboard(name: "Register", bundle: Bundle.main).instantiateInitialViewController() as? UINavigationController,
            let registerController = navigator.topViewController as? RegisterController {
            self.navigationController?.pushViewController(registerController, animated: true)
            
            registerController.isSocialLogin = false
            registerController.email = emailField.text
            registerController.navigationItem.leftBarButtonItem = nil
        }
    }
    
    @IBAction func tryLogin(_ sender: Any) {
        if let email = emailField.text, email.isValidateEmail() {
            ApiService.shared.requestAuthenticatedCode(email, loginType: .email, completion: { (res) in
                if res == "NO_USER" {
                    let alert = AlertService.shared.confirm(self, title: "", message: "존재하지 않는 이메일 입니다.\n회원가입을 하시겠습니까?", cancel: nil, confirm: {
                        self.register(sender)
                    })
                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "authCodeLoginController") as? AuthCodeLoginController {
                        controller.email = email
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            })
        } else {
            self.view.presentToast("정확한 이메일 주소를 입력해주세요.")
        }
    }
}
