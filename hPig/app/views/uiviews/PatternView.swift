//
//  PatternView.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 14..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreGraphics

class PatternView: UIView {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var koreanLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        XibService.shared.layoutXibViews(superview: self, nibName: "pattern_view", viewLayoutBlock: nil)
        initBgView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        XibService.shared.layoutXibViews(superview: self, nibName: "pattern_view", viewLayoutBlock: nil)
        initBgView()
    }
    
    private func initBgView() {
//        bgView.clipsToBounds = true
//        bgView.layer.cornerRadius = 8.0
    }
    
    func update(pattern: PATTERN) {
        if let english = pattern.english, let korean = pattern.korean, let meaning = pattern.mean, let info = pattern.info {
            englishLabel.attributedText = SubtitleService.shared.buildAttributedString(english)
            koreanLabel.text = korean
            meaningLabel.text = meaning
            infoLabel.text = info
        }
    }
}
