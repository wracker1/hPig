//
//  SearchCell.swift
//  hPig
//
//  Created by 이동현 on 2017. 2. 26..
//  Copyright © 2017년 wearespeakingtube. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var sessionImage: UIImageView!
    @IBOutlet weak var sessionTitle: UILabel!
    @IBOutlet weak var sessionDesc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(_ keyword: String, session: Session) {
        
        if let title = session.title?.attributedString(with: keyword),
            let desc = session.sessionDescription?.attributedString(with: keyword) {
        
            sessionTitle.attributedText = title
            sessionDesc.attributedText = desc
        }
        
        if let url = session.image {
            ImageDownloadService.shared.get(url: url, filter: nil, completionHandler: { (res) in
                self.sessionImage.image = res.result.value
            })
        }
    }

}
