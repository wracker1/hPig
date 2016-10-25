//
//  StudyHistoryCell.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 17..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreData
import CoreGraphics

class StudyHistoryCell: UICollectionViewCell {
    
    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var completeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    var history: HISTORY? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        progressLabel.clipsToBounds = true
        completeLabel.clipsToBounds = true
        durationLabel.clipsToBounds = true
        
        progressLabel.layer.cornerRadius = 5.0
        completeLabel.layer.cornerRadius = 5.0
        durationLabel.layer.cornerRadius = 5.0
    }
    
    func update(history: HISTORY) {
        self.history = history
        
        if let url = history.image,
            let title = history.title,
            let duration = history.duration {
            
            titleLabel.text = title
            durationLabel.text = duration
            
            let position = Int(history.position)
            let maxposition = Int(history.maxposition)
            
            if position == maxposition {
                completeLabel.isHidden = false
                progressLabel.isHidden = true
            } else {
                completeLabel.isHidden = true
                progressLabel.isHidden = false
                progressLabel.text = "\(Int(Float(position) / Float(maxposition) * 100))%"
            }
            
            ImageDownloadService.shared.get(url: url, filter: nil, completionHandler: { (res) in
                if let image = res.result.value {
                    self.sessionImageView.image = image
                }
            })
        }
        
    }
    
}
