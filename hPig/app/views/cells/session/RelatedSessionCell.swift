//
//  RelatedSessionCell.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 27..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class RelatedSessionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func update(session: Session) {
        self.imageView.image = nil
        
        ImageDownloadService.shared.get(url: session.image, filter: nil) { (res) in
            self.imageView.image = res.result.value
        }
        
        titleLabel.text = session.title
        titleLabel.sizeToFit()
    }
}
