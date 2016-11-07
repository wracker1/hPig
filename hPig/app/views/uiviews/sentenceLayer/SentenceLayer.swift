//
//  SentenceLayer.swift
//  hPig
//
//  Created by Jesse on 2016. 11. 7..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class SentenceLayer: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var koreanLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        LayoutService.shared.loadNib("sentence_layer", superview: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        LayoutService.shared.loadNib("sentence_layer", superview: self)
    }

    func update(_ word: WORD) {
        if let sentence = word.sentence, let item = word.word {
            let range = (sentence as NSString).range(of: item, options: .caseInsensitive)
            let attributedString = NSMutableAttributedString(string: sentence)
            attributedString.addAttributes([NSForegroundColorAttributeName: SubtitlePointColor], range: range)
            
            englishLabel.attributedText = attributedString
            
            koreanLabel.text = word.korean
        }
    }
}
