//
//  PatternCell.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 5..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreData

class PatternCell: UITableViewCell, hTableViewCell {
    typealias Item = PATTERN
    
    private var isHiddenDesc = true
    private var hiddenConsts = [NSLayoutConstraint]()
    private var visibleConsts = [NSLayoutConstraint]()
    
    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var descView: UIView!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var koreanLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.sessionImageView.translatesAutoresizingMaskIntoConstraints = false
        self.meaningLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String : Any] = [
            "image": sessionImageView,
            "meaning": meaningLabel,
            "desc": descView,
            "eng": englishLabel,
            "kor": koreanLabel
        ]
        
        self.hiddenConsts = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[image(>=80)]-[meaning]-|",
            options: .alignAllTop,
            metrics: nil,
            views: views) + NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[image(>=60)]-|",
                options: .alignAllCenterY,
                metrics: nil,
                views: views) + NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-[meaning]-|",
                    options: .alignAllCenterY,
                    metrics: nil,
                    views: views)
        
        self.visibleConsts = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[image(>=80)]-[meaning]-|",
            options: .alignAllTop,
            metrics: nil,
            views: views) + NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-[desc]-|",
                options: .alignAllCenterX,
                metrics: nil,
                views: views) + NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-[image]-[desc]-|",
                    options: .alignAllLeading,
                    metrics: nil,
                    views: views) + NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|-[meaning]-[desc]-|",
                        options: .alignAllTrailing,
                        metrics: nil,
                        views: views)
        
        setConstsForDescView(views: views)
        show()
    }
    
    private func setConstsForDescView(views: [String: Any]) {
        
        englishLabel.translatesAutoresizingMaskIntoConstraints = false
        koreanLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-[eng]-|",
                options: .alignAllLeading,
                metrics: nil,
                views: views) + NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-[kor]-|",
                    options: .alignAllLeading,
                    metrics: nil,
                    views: views) + NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|-[eng]-[kor]-|",
                        options: .alignAllLeading,
                        metrics: nil,
                        views: views)
        )
    }
    
    private func hide() {
        self.contentView.removeConstraints(visibleConsts)
        self.contentView.addConstraints(hiddenConsts)
        self.isHiddenDesc = true
        self.descView.isHidden = true
        self.updateConstraintsIfNeeded()
    }
    
    private func show() {
        self.contentView.removeConstraints(hiddenConsts)
        self.contentView.addConstraints(visibleConsts)
        self.isHiddenDesc = false
        self.descView.isHidden = false
        self.updateConstraintsIfNeeded()
    }
    
    func toggle() {
        if isHiddenDesc {
            show()
        } else {
            hide()
        }
    }
    
    func update(data: Item) -> UITableViewCell {
        if let url = data.image {
            self.sessionImageView.image = nil
            
            ImageDownloadService.shared.get(url: url, filter: nil, completionHandler: { (data) in
                self.sessionImageView.image = data.result.value
                
                self.updateConstraintsIfNeeded()
            })
        }
        
        if let mean = data.mean, let english = data.english, let korean = data.korean {
//            self.updateConstraintsIfNeeded()
            
            meaningLabel.text = mean
            englishLabel.attributedText = SubtitleService.shared.buildAttributedString(english)
            koreanLabel.text = korean
            
            englishLabel.sizeToFit()
            koreanLabel.sizeToFit()
            
            print("\(englishLabel.frame)")
            print("\(koreanLabel.frame)")
            
            self.updateConstraintsIfNeeded()
        }

        return self
    }
}
