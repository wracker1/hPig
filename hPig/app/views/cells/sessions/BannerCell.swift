//
//  BannerCell.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class BannerCell: UITableViewCell, hTableViewCell {
    
    typealias Item = Session

    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    func update(data item: Session) -> UITableViewCell {
        self.bannerImageView.image = nil
        self.iconView.image = nil
        
        if let imageUrl = item.image {
            ImageDownloadService.shared.get(url: imageUrl, filter: nil) { (res: DataResponse<Image>) in
                self.bannerImageView.image = res.result.value
            }
        }
        
        if let channelImageUrl = item.channelImage {
            ImageDownloadService.shared.get(url: channelImageUrl, filter: nil) { (res: DataResponse<Image>) in
                self.iconView.image = res.result.value
            }
        }
        
        self.titleLabel.text = item.title
        self.nameLabel.text = item.channelName
        
        return self
    }

}
