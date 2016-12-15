//
//  RegisterController.swift
//  hPig
//
//  Created by Jesse on 2016. 12. 15..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreGraphics

class RegisterController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var serviceAgree: UISwitch!
    @IBOutlet weak var personalInfoAgree: UISwitch!
    @IBOutlet weak var registerButton: UIButton!
    
    var user: User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.borderColor = secondPointColor.cgColor
        profileImageView.layer.borderWidth = 2.0
        
        registerButton.layer.borderColor = secondPointColor.cgColor
        registerButton.layer.borderWidth = 1.0
        
        
        if let userData = user {
            
            if let profileUrl = userData.profileImage {
                ImageDownloadService.shared.get(url: profileUrl, filter: nil, completionHandler: { (res) in
                    self.profileImageView.image = res.result.value
                })
            }
            
            nameField.placeholder = userData.name
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func registerUser(_ sender: Any) {
        if serviceAgree.isOn && personalInfoAgree.isOn {
            if let userData = user {
                var name: String? = nil
                
                if let tmp = nameField.text, !tmp.isEmpty {
                    name = tmp
                } else if let tmp = nameField.placeholder, !tmp.isEmpty {
                    name = tmp
                }
                
                AuthenticateService.shared.joinUser(user: userData, name: name, completion: { (success) in
                    if success {
                        NotificationCenter.default.post(name: kRegisterCompletion, object: userData, userInfo: nil)
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        } else {
            self.view.presentToast("약관 동의를 확인해주세요.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let web = segue.destination as? hWebViewController {
            switch segue.identifier ?? "" {
            case "showServiceAgree":
                web.title = "서비스 이용약관 동의"
                web.url = "http://speakingtube.cafe24.com/use.html"
                
            case "showPersonalAgree":
                web.title = "개인정보 제공 동의"
                web.url = "http://speakingtube.cafe24.com/info.html"
                
            default:
                break
            }
        }
        
    }
}
