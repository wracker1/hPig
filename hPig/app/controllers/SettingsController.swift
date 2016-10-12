//
//  SettingsController.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import MessageUI

enum SettingCellType {
    case login
    case sendMail
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
            ["type": SettingCellType.version, "value": "\(appVersion) (\(buildVersion))"],
            ["type": SettingCellType.sendMail],
            ["type": SettingCellType.login]
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
        let type = data["type"] as! SettingCellType
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(type: type), for: indexPath)
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
                // TODO - show failure alert
            }
        default:
            print(data)
        }
        
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func cellIdentifier(type: SettingCellType) -> String {
        switch type {
        case .login:
            return "ActionCell"
        case .sendMail:
            return "ActionCell"
        default:
            return "SettingCell"
        }
    }

}
