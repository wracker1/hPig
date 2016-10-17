//
//  MyInfoController.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import AlamofireImage
import CoreGraphics

class MyInfoController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var passNameLabel: UILabel!
    @IBOutlet weak var passDurationLabel: UILabel!
    @IBOutlet weak var studyTotalDurationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        profileImageView.clipsToBounds = true
//        profileImageView.layer.cornerRadius = 40.0
        
        studyTotalDurationView.layer.cornerRadius = 5.0
        studyTotalDurationView.layer.borderColor = UIColor.lightGray.cgColor
        studyTotalDurationView.layer.borderWidth = 1.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AuthenticateService.shared.user { (user) in
            self.loadPersonalInfoView(user)
        }
    }
    
    private func loadPersonalInfoView(_ user: User?) {
        if let registerdUser = user {
            nameLabel.text = "\(registerdUser.name) 님"
            idLabel.text = "| \(registerdUser.id)"
            
            ImageDownloadService.shared.get(
                url: registerdUser.profileImage,
                filter: nil,
                completionHandler: { (res) in
                    if let image = res.result.value {
                        self.profileImageView.image = image
                    }
            })
        }
    }

}
