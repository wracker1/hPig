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
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func register(_ sender: Any) {
        if let navigator = UIStoryboard(name: "Register", bundle: Bundle.main).instantiateInitialViewController() as? UINavigationController,
            let registerController = navigator.topViewController as? RegisterController {
            self.navigationController?.pushViewController(registerController, animated: true)
            
            registerController.isSocialLogin = false
            registerController.navigationItem.leftBarButtonItem = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let authCodeLogin = segue.destination as? AuthCodeLoginController {
            authCodeLogin.email = emailField.text
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "checkAuthCode", let email = emailField.text {
            if email.isValidateEmail() {
                return true
            } else {
                self.view.presentToast("정확한 이메일 주소를 입력해주세요.")
                return false
            }
        } else {
            return true
        }
    }
}
