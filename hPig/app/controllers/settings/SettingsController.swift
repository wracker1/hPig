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
    
    private func cellIds() -> [String] {
        if AuthenticateService.shared.isOn() {
            return ["versionCell", "pushCell", "faqCell", "mailCell", "purchaseCell", "delDataCell", "loginCell"]
        } else {
            return ["versionCell", "faqCell", "mailCell", "purchaseCell", "delDataCell", "loginCell"]
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellIds().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = cellIds()[indexPath.row]
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
        let id = cellIds()[indexPath.row]
        
        switch id {
        case "loginCell":
            toggleLogin()
            
        case "mailCell":
            if MFMailComposeViewController.canSendMail() {
                presentMailComposer()
            } else {
                self.view.presentToast("'설정 > Mail'을 확인 하고, 계정 설정을 해주세요.")
            }
        default:
            print(id)
        }
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
        return "이용안내"
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
