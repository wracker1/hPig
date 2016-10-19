//
//  SessionCell.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import CoreGraphics

class SessionCell: UITableViewCell, hTableViewCell {
    
    typealias Item = Session

    @IBOutlet weak var contentWrapView: UIView!
    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var channelButton: ChannelButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    
    private var constCateImage: NSLayoutConstraint? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentWrapView.layer.shadowOpacity = 0.3
        contentWrapView.layer.shadowColor = UIColor.black.cgColor
        contentWrapView.layer.shadowOffset = CGSize(width: 0.1, height: 0.1)
        
        channelButton.clipsToBounds = true
        channelButton.layer.cornerRadius = 19.0
    }
    
    private func levelText(level: String) -> String {
        let value = Int(level)!
        let filled = (0..<value).map { _ in
            return "★"
        }.joined(separator: "")
        
        let empty = (0..<(3 - value)).map { _ in
            return "☆"
        }.joined(separator: "")
        
        return "ㆍ 난이도 \(filled)\(empty)"
    }
    
    func update(data item: Session) -> UITableViewCell {
        self.channelButton.session = item
        
        sessionImageView.clipsToBounds = true
        self.sessionImageView.image = nil
        self.channelButton.imageView?.image = nil
        
        if let const = constCateImage {
            categoryImageView.removeConstraint(const)
        }
        
        ImageDownloadService.shared.get(url: item.image, filter: nil) { (res: DataResponse<Image>) in
            self.sessionImageView.image = res.result.value
        }
        
        ImageDownloadService.shared.get(url: item.channelImage, filter: nil) { (res: DataResponse<Image>) in
            self.channelButton.setImage(res.result.value, for: .normal)
        }
        
        self.titleLabel.text = item.title
        self.channelNameLabel.text = item.channelName
        self.descriptionLabel.text = item.sessionDescription
        
        if let cateImage = UIImage(named: "cate_\(item.category.lowercased())") {
            let aspect = cateImage.size.width / cateImage.size.height
            let const = NSLayoutConstraint(
                item: self.categoryImageView,
                attribute: .width,
                relatedBy: .equal,
                toItem: self.categoryImageView,
                attribute: .height,
                multiplier: aspect,
                constant: 0.0)
            
            self.constCateImage = const
            self.categoryImageView.image = cateImage
            self.categoryImageView.addConstraint(const)
        }
        
        
        
        self.levelLabel.text = self.levelText(level: item.level)
        
        let viewCount = Int(item.viewcnt)! / 1000
        self.viewCountLabel.text = "\(viewCount)k"

        return self
    }

}
