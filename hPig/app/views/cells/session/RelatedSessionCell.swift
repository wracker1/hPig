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
    
    var session: Session? = nil
    
    func update(session: Session) {
        self.session = session
        self.imageView.image = nil
        
        if let imageUrl = session.image {
            ImageDownloadService.shared.get(url: imageUrl, filter: nil) { (res) in
                self.imageView.image = res.result.value
            }
        }
        
        titleLabel.text = session.title
        titleLabel.sizeToFit()
    }
}
