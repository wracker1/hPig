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
    
    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    
    func update(data: Item) -> UITableViewCell {
        if let url = data.image {
            ImageDownloadService.shared.get(url: url, filter: nil, completionHandler: { (data) in
                self.sessionImageView.image = data.result.value
            })
        }
        
        if let english = data.english, let mean = data.mean {
            englishLabel.attributedText = SubtitleService.shared.buildAttributedString(english)
            
            meaningLabel.text = mean
        }
        
        return self
    }
}
