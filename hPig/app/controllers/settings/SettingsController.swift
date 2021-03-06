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
        // "withdrawalCell" -> 탈퇴기능셀, 탈퇴를 하고 새로가입하면 무료로 다시 이용가능하기 때문에 임시로 뺀다.
        
        if LoginService.shared.isOn() {
            return [
                "pass": ["purchaseCell"],
                "my": ["versionCell", "pushCell", "delDataCell", "loginCell", "withdrawalCell"],
                "info": ["faqCell", "mailCell"]
                
            ]
        } else {
            return [
                "pass": ["purchaseCell"],
                "my": ["versionCell", "delDataCell", "loginCell", "withdrawalCell"],
                "info": ["faqCell", "mailCell"]
                
            ]
        }
    }
    
    private func sectionTitle(_ section: Int) -> String? {
        switch section {
        case 0:
            return "이용권"
            
        case 1:
            return "내 정보"
            
        case 2:
            return "이용 안내"
            
        default:
            return nil
        }
    }
    
    private func data(in section: Int) -> [String] {
        switch section {
        case 0:
            return cellIds()["pass"] ?? [String]()
        case 1:
            return cellIds()["my"] ?? [String]()
        case 2:
            return cellIds()["info"] ?? [String]()
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
            cell.textLabel?.text = LoginService.shared.isOn() ? "로그아웃" : "로그인"
            return cell
            
        default:
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = cellId(indexPath)
        
        switch id {
        case "loginCell":
            toggleLogin(tableView.cellForRow(at: indexPath))
            
        case "withdrawalCell":
            withdrawalUser()
            
        case "couponRegisterCell":
            if LoginService.shared.isOn() {
                presentRegisterCouponAlert()
            } else {
                LoginService.shared.tryLogin(self,
                                             sourceView: tableView.cellForRow(at: indexPath),
                                             completion: { (_) in
                    self.presentRegisterCouponAlert()
                })
            }
            
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
    
    private func withdrawalUser() {
        let alert = AlertService.shared.confirm(self, title: "회원탈퇴", message: "정말 탈퇴하시려고요? ㅠㅠ", cancel: nil, confirm: {
            LoginService.shared.user({ (_, u) in
                if let user = u {
                    ApiService.shared.withdrawalUser(user.id, loginType: user.loginType, completion: { (success) in
                        if success {
                            CoreDataService.shared.deleteUserData(user.id)
                            
                            self.view.presentToast("탈퇴 하였습니다.")
                        }
                        
                        LoginService.shared.logout(completion: {
                            self.tableView.reloadData()
                        })
                    })
                }
            })
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func presentRegisterCouponAlert() {
        LoginService.shared.user({ (tuser, user) in
            if let uData = user {
                let alert = UIAlertController(title: "쿠폰 등록", message: "ㆍ쿠폰 번호를 입력해주세요.\nㆍ쿠폰 번호는 10자리입니다.\nㆍ쿠폰 패스 내역이 통합되어 반영됩니다.", preferredStyle: .alert)
                
                alert.messageLabel()?.textAlignment = .left
                
                alert.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = "쿠폰 번호 입력"
                })
                
                alert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))
                
                alert.addAction(UIAlertAction(title: "등록", style: .default, handler: { (_) in
                    if let couponNumber = alert.textFields?.first?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                        
                        if couponNumber.characters.count == 10 {
                            ApiService.shared.registerCoupon(uData.id, loginType: uData.loginType, coupon: couponNumber, completion: { (message) in
                                self.view.presentToast(message)
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
            LoginService.shared.user({ (_, u) in
                if let user = u {
                    ApiService.shared.updateRemotePushSetting(user.id, loginType: user.loginType, isOn: sw.isOn)
                }
            })
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func toggleLogin(_ cell: UITableViewCell?) {
        let authenticate = LoginService.shared
        if authenticate.isOn() {
            authenticate.logout {
                self.tableView.reloadData()
            }
        } else {
            authenticate.tryLogin(self, sourceView: cell) { (user) in
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
