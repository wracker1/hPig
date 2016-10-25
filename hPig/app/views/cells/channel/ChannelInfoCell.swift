//
//  ChannelInfoCell.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 25..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreGraphics

class ChannelInfoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bannerView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watcherCntLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 20
    }
    
    func loadData(_ channel: Channel, completion: ((CGFloat) -> Void)?) {
        self.titleLabel.text = channel.name
        self.watcherCntLabel.text = channel.subCnt
        self.descLabel.text = channel.desc
        self.descLabel.sizeToFit()
        
        let frame = self.descLabel.frame
        let height = frame.origin.y + frame.size.height + 21
        
        ImageDownloadService.shared.get(url: channel.image, filter: nil, completionHandler: { (res) in
            self.imageView.image = res.result.value
        })
        
        ImageDownloadService.shared.get(url: channel.banner, filter: nil, completionHandler: { (res) in
            self.bannerView.image = res.result.value
        })
        
        
        
        if let callback = completion {
            callback(height)
        }
    }
    
    
}
