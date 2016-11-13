//
//  SubtitleCell.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 25..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import AVFoundation

class SubtitleCell: UITableViewCell {
    
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var koreanLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let bgView = UIView()
        bgView.backgroundColor = RGBA(37, g: 37, b: 37, a: 1)
        self.selectedBackgroundView = bgView
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didReceiveToggleKoreanLabelEvent),
                                               name: Global.kToggleKoreanLabelVisible,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didReceiveToggleEnglishLabelEvent),
                                               name: Global.kToggleEnglishLabelVisible,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepareForReuse() {
        englishLabel.textColor = UIColor.black
        koreanLabel.textColor = UIColor.black
        
        super.prepareForReuse()
    }
    
    func update(_ subtitle: BasicStudy) {
        englishLabel.text = subtitle.english
        koreanLabel.text = subtitle.korean
    }
    
    func didReceiveToggleKoreanLabelEvent(notif: NSNotification) {
        if let userInfo = notif.userInfo {
            if let value = userInfo["value"] {
                koreanLabel.isHidden = !(value as! Bool)
            }
        }
    }
    
    func didReceiveToggleEnglishLabelEvent(notif: NSNotification) {
        if let userInfo = notif.userInfo {
            if let value = userInfo["value"] {
                englishLabel.isHidden = !(value as! Bool)
            }
        }
    }
}

