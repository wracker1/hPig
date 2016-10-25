//
//  SessionFeedCell.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 25..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import CoreGraphics

class SessionFeedCell: UICollectionViewCell {
    
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var cateImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var channelImageButton: ChannelButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var outerWidth: NSLayoutConstraint!
    @IBOutlet weak var innerWidth: NSLayoutConstraint!
    
    private let maxWidth: CGFloat = 414
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        wrapper.layer.shadowOpacity = 0.3
        wrapper.layer.shadowColor = UIColor.black.cgColor
        wrapper.layer.shadowOffset = CGSize(width: 0.1, height: 0.1)
        
        channelImageButton.clipsToBounds = true
        channelImageButton.contentMode = .scaleAspectFill
        channelImageButton.layer.cornerRadius = 20.0
        
        self.adjustConsts(UIScreen.main.bounds.size)
        
        NotificationCenter.default.addObserver(forName: Global.kViewWillTransition, object: nil, queue: nil) { (notif) in
            if let value = notif.object as? NSValue {
                let size = value.cgSizeValue
                self.adjustConsts(size)
            }
        }
    }
    
    private func adjustConsts(_ size: CGSize) {
        if size.width > maxWidth {
            let i = Int(size.width) / Int(maxWidth)
            let width = floor((size.width / CGFloat(i + 1)))
            
            self.outerWidth.constant = width
            self.innerWidth.constant = width - 8
        } else {
            self.outerWidth.constant = size.width
            self.innerWidth.constant = size.width
        }
        
        self.layoutIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func update(data item: Session) {
        self.channelImageButton.session = item

        sessionImageView.clipsToBounds = true
        self.sessionImageView.image = nil
        self.channelImageButton.imageView?.image = nil

        if let imageUrl = item.image {
            ImageDownloadService.shared.get(url: imageUrl, filter: nil) { (res: DataResponse<Image>) in
                self.sessionImageView.image = res.result.value
            }
        }

        if let channelImageUrl = item.channelImage {
            ImageDownloadService.shared.get(url: channelImageUrl, filter: nil) { (res: DataResponse<Image>) in
                self.channelImageButton.setImage(res.result.value, for: .normal)
            }
        }

        self.titleLabel.text = item.title
        self.channelNameLabel.text = item.channelName
        self.descriptionLabel.text = item.sessionDescription

        if let category = item.categoryName,
            let cateImage = UIImage(named: "cate_\(category.lowercased())") {
            self.cateImageView.image = cateImage
        }

        if let level = item.level {
            self.levelLabel.text = self.levelText(level: level)
        }
        
        if let viewCount = item.viewcnt, let count = Int(viewCount) {
            self.viewCountLabel.text = "\(count / 1000)k"
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
}
