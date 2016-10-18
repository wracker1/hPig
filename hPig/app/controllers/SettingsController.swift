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

enum SettingCellType {
    case login
    case sendMail
    case faq
    case version
}

class SettingsController: UITableViewController, MFMailComposeViewControllerDelegate {
    private let menu: [[String: Any]] = {
        var appVersion = "1.0.0"
        var buildVersion = "1"
        
        if let info = Bundle.main.infoDictionary {
            if let data = info["CFBundleShortVersionString"], let version = data as? String {
                appVersion = version
            }
            
            if let data = info["CFBundleVersion"], let build = data as? String {
                buildVersion = build
            }
        }
        
        let items = [
            ["type": SettingCellType.version, "id": "SettingCell" , "value": "\(appVersion) (\(buildVersion))"],
            ["type": SettingCellType.faq, "id": "FAQCell"],
            ["type": SettingCellType.sendMail, "id": "ActionCell"],
            ["type": SettingCellType.login, "id": "ActionCell"]
        ]
        
        return items
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = menu[indexPath.row]
        let id = data["id"] as! String
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        return updateCell(cell: cell, data: data)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = menu.get(indexPath.row) {
            actionCell(data: data)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "이용안내"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let webController = segue.destination as? hWebViewController {
            webController.url = "http://speakingtube.cafe24.com/faq.html"
            webController.title = "자주 묻는 질문"
        }
    }
    
    private func updateCell(cell: UITableViewCell, data: [String : Any]) -> UITableViewCell {
        let type = data["type"] as! SettingCellType
        
        switch type {
        case .login:
            cell.textLabel?.text = AuthenticateService.shared.isOn() ? "로그아웃" : "로그인"
            
        case .sendMail:
            cell.textLabel?.text = "고객의견"
            
        case .version:
            cell.textLabel?.text = "버전정보"
            cell.detailTextLabel?.text = data["value"] as? String
        case .faq:
            cell.textLabel?.text = "자주 묻는 질문"
        }
        
        return cell
    }
    
    private func actionCell(data: [String : Any]) {
        let type = data["type"] as! SettingCellType
        
        switch type {
        case .login:
            let authenticate = AuthenticateService.shared
            if authenticate.isOn() {
                authenticate.logout {
                    self.tableView.reloadData()
                }
            } else {
                authenticate.tryLogin(viewController: self) { (isSuccess) in
                    if isSuccess {
                        self.tableView.reloadData()
                    }
                }
            }
        case .sendMail:
            if MFMailComposeViewController.canSendMail() {
                var version = "unknown"
                let tubeMail = "wearespeakingtube@gmail.com"
                
                let versionData = menu.find { (elem) in
                    if let type = elem["type"] as? SettingCellType {
                        return type == .version
                    } else {
                        return false
                    }
                }
                
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([tubeMail])
                mail.setSubject("스피킹 튜브 - 문의 및 개선 사항")
                
                if let data = versionData, let item = data["value"], let v = item as? String {
                    version = v
                }
                
                let body = "이용해 주셔서 감사합니다^^\n불편한 점이나 개선 사항이 있으시면 의견 남겨주세요.\n\n- 앱 버전: \(version)\n- 단말기 정보: \(UIDevice.current.localizedModel), \(UIDevice.current.systemVersion)\n- 받는 사람: \(tubeMail)\n- 문의 내용: "
                mail.setMessageBody(body, isHTML: false)
                
                present(mail, animated: true)
            } else {
                self.view.presentToast("'설정 > Mail'을 확인 하고, 계정 설정을 해주세요.")
            }
        default:
            print(data)
        }
        
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
