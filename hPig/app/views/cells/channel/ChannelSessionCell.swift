//
//  ChannelSessionCell.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 19..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class ChannelSessionCell: UICollectionViewCell {
    
    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    func update(session: Session) {
        titleLabel.text = session.title
        durationLabel.text = session.duration
        
        ImageDownloadService.shared.get(url: session.image, filter: nil) { (res) in
            self.sessionImageView.image = res.result.value
        }
    }
}
