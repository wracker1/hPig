//
//  PatternCell.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 5..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreData
import CoreGraphics

class PatternCell: UITableViewCell, hTableViewCell {
    typealias Item = PATTERN
    
    private var isHiddenDesc = true
    private var hiddenConsts = [NSLayoutConstraint]()
    private var visibleConsts = [NSLayoutConstraint]()
    private var descConsts = [NSLayoutConstraint]()
    
    @IBOutlet weak var sessionImageButton: UIButton!
    @IBOutlet weak var meaningLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sessionImageButton.layer.cornerRadius = 8.0
        sessionImageButton.clipsToBounds = true
        
        if let imageView = sessionImageButton.imageView {
            imageView.contentMode = .scaleAspectFill
        }
    }
    
    func update(data: Item) -> UITableViewCell {
        self.sessionImageButton.setImage(nil, for: .normal)
        
        if let url = data.image {
            ImageDownloadService.shared.get(url: url, filter: nil, completionHandler: { (data) in
                self.sessionImageButton.setImage(data.result.value, for: .normal)
                self.updateConstraintsIfNeeded()
            })
        }
        
        if let meaning = data.mean {
            meaningLabel.text = meaning
        }

        return self
    }
}
