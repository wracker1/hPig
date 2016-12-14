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
                                               selector: #selector(self.didReceiveToggleKoreanLabelEvent(notif:)),
                                               name: kToggleKoreanLabelVisible,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didReceiveToggleEnglishLabelEvent(notif:)),
                                               name: kToggleEnglishLabelVisible,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.cellSelected(notif:)),
                                               name: kSelectCellWithIndexPath,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func update(_ subtitle: BasicStudy, indexPath: IndexPath) {
        self.englishLabel.text = subtitle.english
        self.koreanLabel.text = subtitle.korean
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
    
    func cellSelected(notif: NSNotification) {
        toggleLabelColor()
    }
    
    func toggleLabelColor() {
        if self.isSelected {
            englishLabel.textColor = SubtitlePointColor
            koreanLabel.textColor = UIColor.white
        } else {
            englishLabel.textColor = UIColor.black
            koreanLabel.textColor = UIColor.black
        }
        
    }
}

