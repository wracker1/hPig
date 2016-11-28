//
//  SettingsController.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import MessageUI
import Toast_Swift

class SettingsController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    private func cellIds() -> [String : [String]] {
        if AuthenticateService.shared.isOn() {
            return [
                "pass": ["purchaseCell", "couponRegisterCell"],
                "info": ["faqCell", "mailCell"],
                "my": ["versionCell", "pushCell", "delDataCell", "loginCell"]
            ]
            
        } else {
            return [
                "pass": ["purchaseCell", "couponRegisterCell"],
                "info": ["faqCell", "mailCell"],
                "my": ["versionCell", "delDataCell", "loginCell"]
            ]
        }
    }
    
    private func sectionTitle(_ section: Int) -> String? {
        switch section {
        case 0:
            return "이용권"
            
        case 1:
            return "이용 안내"
            
        case 2:
            return "내 정보"
            
        default:
            return nil
        }
    }
    
    private func data(in section: Int) -> [String] {
        switch section {
        case 0:
            return cellIds()["pass"] ?? [String]()
        case 1:
            return cellIds()["info"] ?? [String]()
        case 2:
            return cellIds()["my"] ?? [String]()
        default:
            return [String]()
        }
    }
    
    private func cellId(_ indexPath: IndexPath) -> String {
        let sectionItems = data(in: indexPath.section)
        return sectionItems[indexPath.row]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data(in: section).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = cellId(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        
        switch id {
        case "versionCell":
            cell.detailTextLabel?.text = version()
            return cell
            
        case "loginCell":
            cell.textLabel?.text = AuthenticateService.shared.isOn() ? "로그아웃" : "로그인"
            return cell
            
        default:
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = cellId(indexPath)
        
        switch id {
        case "loginCell":
            toggleLogin()
            
        case "couponRegisterCell":
            presentRegisterCouponAlert()
            
        case "mailCell":
            if MFMailComposeViewController.canSendMail() {
                presentMailComposer()
            } else {
                self.view.presentToast("'설정 > Mail'을 확인 하고, 계정 설정을 해주세요.")
            }
        default:
            print(id)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func presentRegisterCouponAlert() {
        AuthenticateService.shared.user({ (userInfo) in
            if let user = userInfo {
                let alert = UIAlertController(title: "쿠폰 등록", message: "ㆍ쿠폰 번호를 입력해주세요.\nㆍ쿠폰 번호는 10자리입니다.\nㆍ쿠폰 패스 내역이 통합되어 반영됩니다.", preferredStyle: .alert)
                
                alert.messageLabel()?.textAlignment = .left
                
                alert.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = "쿠폰 번호 입력"
                })
                
                alert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))
                
                alert.addAction(UIAlertAction(title: "등록", style: .default, handler: { (_) in
                    if let couponNumber = alert.textFields?.first?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                        
                        if couponNumber.characters.count == 10 {
                            let params = ["id": user.id, "coupon": couponNumber.uppercased()]
                            
                            NetService.shared.get(path: "/svc/api/user/update/coupon", parameters: params).responseString(completionHandler: { (res) in
                                if let result = res.result.value {
                                    switch result.lowercased() {
                                        case "success":
                                        AuthenticateService.shared.updateTubeUserInfo(user.id, completion: nil)
                                        self.view.presentToast("등록 하였습니다.")

                                        case "duplicated":
                                        self.view.presentToast("이미 등록된 쿠폰 번호입니다.")
                                        
                                        case "not_available":
                                        self.view.presentToast("유효하지 않은 쿠폰 번호입니다.")
                                        
                                        default:
                                        self.view.presentToast("등록에 실패하였습니다. 다시 시도해주세요.")
                                    }
                                }
                            })
                        } else {
                            self.view.presentToast("정확한 쿠폰번호를 입력해주세요.")
                        }
                    }
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func updatePushNotiSetting(_ sender: AnyObject) {
        if let sw = sender as? UISwitch {
            AuthenticateService.shared.user({ (user) in
                if let tubeUser = user {
                    let param = [
                        "id": tubeUser.id,
                        "pushyn": sw.isOn ? "Y" : "N"
                    ]
                    
                    NetService.shared.get(path: "/svc/api/user/update/pushyn", parameters: param).responseString(completionHandler: { (res) in
                        if let message = res.result.value {
                            print(message)
                        }
                    })
                }
            })
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func toggleLogin() {
        let authenticate = AuthenticateService.shared
        if authenticate.isOn() {
            authenticate.logout {
                self.tableView.reloadData()
            }
        } else {
            authenticate.tryLogin(self) { (user) in
                if user != nil {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func presentMailComposer() {
        let tubeMail = "wearespeakingtube@gmail.com"
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients([tubeMail])
        mail.setSubject("스피킹 튜브 - 문의 및 개선 사항")
        
        let body = "이용해 주셔서 감사합니다^^\n불편한 점이나 개선 사항이 있으시면 의견 남겨주세요.\n\n- 앱 버전: \(version())\n- 단말기 정보: \(UIDevice.current.localizedModel), \(UIDevice.current.systemVersion)\n- 받는 사람: \(tubeMail)\n- 문의 내용: "
        mail.setMessageBody(body, isHTML: false)
        
        present(mail, animated: true)
    }
    
    private func version() -> String {
        var appVersion = "unknown"
        var buildVersion = "0"
        
        if let info = Bundle.main.infoDictionary {
            if let data = info["CFBundleShortVersionString"], let version = data as? String {
                appVersion = version
            }
            
            if let data = info["CFBundleVersion"], let build = data as? String {
                buildVersion = build
            }
        }
        
        return "\(appVersion) (\(buildVersion))"
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle(section)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let webController = segue.destination as? hWebViewController {
            webController.url = "http://speakingtube.cafe24.com/faq.html"
            webController.title = "자주 묻는 질문"
        } else {
            AuthenticateService.shared.prepare(self, for: segue, sender: sender)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: nil)
    }
}
