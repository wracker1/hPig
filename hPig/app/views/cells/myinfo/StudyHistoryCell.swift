//
//  StudyHistoryCell.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 17..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreData

class StudyHistoryCell: UICollectionViewCell {
    
    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func update(history: HISTORY) {
        if let url = history.image, let title = history.title {
            titleLabel.text = title
            
            ImageDownloadService.shared.get(url: url, filter: nil, completionHandler: { (res) in
                if let image = res.result.value {
                    self.sessionImageView.image = image
                }
            })
        }
        
    }
    
}
