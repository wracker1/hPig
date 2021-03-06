//
//  DataDeleteController.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 23..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class DataDeleteController: UITableViewController {
    
    private let ids = ["delHistory", "delTimelog", "delPattern", "delWord"]
    private var switches = [String: UISwitch]()
    private var userId: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delButton = UIButton(type: .system)
        delButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        delButton.setTitleColor(secondPointColor, for: .normal)
        delButton.setTitle("삭제", for: .normal)
        delButton.addTarget(self, action: #selector(self.del), for: .touchUpInside)
        delButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: delButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        LoginService.shared.user { (_, u) in
            if let user = u {
                self.userId = user.name
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ids.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = ids[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        
        let opt = cell.subviews.first?.subviews.find({ (item) -> Bool in
            return (item as? UISwitch) != nil
        })
        
        if let sw = opt as? UISwitch {
            switches[id] = sw
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let name = userId {
            return "\(name)의 데이터만 삭제 됩니다."
        } else {
            return "\(kGuestId)의 데이터만 삭제 됩니다."
        }
    }
    
    func del() {
        let targetIds = switches.flatMap { (k, v) -> String? in
            return v.isOn ? k : nil
        }
        
        let alert = AlertService.shared.confirm(self,
                                                title: "데이터를 삭제 합니다. 진행 하시겠습니까?",
                                                message: nil,
                                                cancel: nil,
                                                confirm: {
                                                    LoginService.shared.user { (tuser, _) in
                                                        CoreDataService.shared.deleteUserData(tuser?.id, itemIds: targetIds)
                                                        self.view.presentToast("삭제 하였습니다.")
                                                    }
        })
        
        self.present(alert, animated: true, completion: nil)
    }
}
