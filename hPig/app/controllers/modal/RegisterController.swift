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

    @IBOutlet weak var socialProfileWrap: UIView!
    @IBOutlet weak var tubeProfileWrap: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var tubeMailField: UITextField!
    @IBOutlet weak var tubeNameField: UITextField!
    
    @IBOutlet weak var serviceAgree: UISwitch!
    @IBOutlet weak var personalInfoAgree: UISwitch!
    @IBOutlet weak var registerButton: UIButton!
    
    var user: User? = nil
    var email: String? = nil
    var isSocialLogin = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.borderColor = secondPointColor.cgColor
        profileImageView.layer.borderWidth = 3.0

        tubeMailField.text = email
        socialProfileWrap.isHidden = !isSocialLogin
        tubeProfileWrap.isHidden = isSocialLogin
        
//        registerButton.cornerRadiusly()
        
        let inputAccessoryView = BasicInputAccessory(frame: self.view.bounds)
        inputAccessoryView.closeButton.addTarget(self, action: #selector(self.resignNameField(_:)), for: .touchUpInside)
        nameField.inputAccessoryView = inputAccessoryView
        
        let tubeMailAccessoryView = BasicInputAccessory(frame: self.view.bounds)
        tubeMailAccessoryView.closeButton.addTarget(self, action: #selector(self.resignTubeMailField), for: .touchUpInside)
        tubeMailField.inputAccessoryView = tubeMailAccessoryView
        
        let tubeNameAccessoryView = BasicInputAccessory(frame: self.view.bounds)
        tubeNameAccessoryView.closeButton.addTarget(self, action: #selector(self.resignTubeNameField), for: .touchUpInside)
        tubeNameField.inputAccessoryView = tubeNameAccessoryView
        
        if let userData = user {
            
            if let profileUrl = userData.profileImage {
                ImageDownloadService.shared.get(url: profileUrl, filter: nil, completionHandler: { (res) in
                    self.profileImageView.image = res.result.value
                })
            }
            
            nameField.placeholder = userData.name
        }
    }
    
    func resignTubeMailField() {
        tubeMailField.resignFirstResponder()
    }
    
    func resignTubeNameField() {
        tubeNameField.resignFirstResponder()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func resignNameField(_ sender: Any) {
        nameField.resignFirstResponder()
    }
    
    @IBAction func registerUser(_ sender: Any) {
        if serviceAgree.isOn && personalInfoAgree.isOn {
            if isSocialLogin {
                registerBySocialAccount()
            } else {
                registerBySpeakingTube()
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
    
    private func registerBySocialAccount() {
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
    }
    
    private func registerBySpeakingTube() {
        if let email = tubeMailField.text, let name = tubeNameField.text {
            validate(email: email, name: name, completion: { (isValid) in
                if isValid {
                    let user = User(id: email, name: name, loginType: .email, profileImage: kDefaultProfileImage)
                    
                    AuthenticateService.shared.joinUser(user: user, name: name, completion: { (success) in
                        if success {
                            NotificationCenter.default.post(name: kRegisterCompletion, object: user, userInfo: nil)
                            
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            })
        }
    }
    
    private func validate(email: String, name: String, completion: ((Bool) -> Void)?) {
        let callback = completion ?? {(_)in}
        var isValid = true
        
        if email.isEmpty || !email.isValidateEmail() {
            self.view.presentToast("정확한 이메일 주소를 입력해주세요.")
            isValid = false
        } else if name.isEmpty {
            self.view.presentToast("이름을 입력해주세요.")
            isValid = false
        }
        
        if isValid {
            ApiService.shared.isDuplicatedUserId(email, loginType: .email, completion: { (isDuplicated) in
                if isDuplicated {
                    self.view.presentToast("이미 사용 중인 이메일입니다.")
                    callback(false)
                } else {
                    callback(true)
                }
            })
        } else {
            callback(isValid)
        }
    }
}
