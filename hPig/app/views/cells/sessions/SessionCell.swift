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
    @IBOutlet weak var cateWidth: NSLayoutConstraint!
    @IBOutlet weak var cateHeight: NSLayoutConstraint!
    
    private var constCateImage: NSLayoutConstraint? = nil
    private var keyword: String? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentWrapView.layer.shadowOpacity = 0.3
        contentWrapView.layer.shadowColor = UIColor.black.cgColor
        contentWrapView.layer.shadowOffset = CGSize(width: 0.1, height: 0.1)
        
        channelButton.contentMode = .scaleAspectFill
        channelButton.layer.cornerRadius = 22.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.sessionImageView.image = nil
        self.channelButton.imageView?.image = nil
        
        if let const = constCateImage {
            categoryImageView.removeConstraint(const)
        }
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
    
    @discardableResult func update(_ item: Session, with keyword: String) -> UITableViewCell {
        self.keyword = keyword
        
        return self.update(data: item)
    }
    
    func update(data item: Session) -> UITableViewCell {
        self.channelButton.session = item
        
        if let imageUrl = item.image {
            ImageDownloadService.shared.get(url: imageUrl, filter: nil) { (res: DataResponse<Image>) in
                self.sessionImageView.image = res.result.value
            }
        }
        
        if let channelImageUrl = item.channelImage {
            ImageDownloadService.shared.get(url: channelImageUrl, filter: nil) { (res: DataResponse<Image>) in
                self.channelButton.setImage(res.result.value, for: .normal)
            }
        }
        
        if let key = keyword {
            self.titleLabel.attributedText = item.title?.attributedString(with: key)
            self.descriptionLabel.attributedText = item.sessionDescription?.attributedString(with: key)
        } else {
            self.titleLabel.text = item.title
            self.descriptionLabel.text = item.sessionDescription
        }
        
        self.channelNameLabel.text = item.channelName
        
        if let category = item.categoryName {
            let cateName = "cate_\(category.lowercased())".replacingOccurrences(of: " ", with: "_")
            let cateImageOpt = UIImage(named: cateName) 
            
            if let cateImage = cateImageOpt {
                let ratio = cateImage.size.width / cateImage.size.height
                cateWidth.constant = cateHeight.constant * ratio
                
                self.categoryImageView.image = cateImage
            }
        }
        
        if let level = item.level {
            self.levelLabel.text = self.levelText(level: level)
        }
        
        if let viewCount = item.viewcnt, let count = Int(viewCount) {
            self.viewCountLabel.text = "\(count / 1000)k"
        }

        return self
    }

}
