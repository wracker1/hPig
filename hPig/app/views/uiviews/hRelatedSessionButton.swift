//
//  hRelatedSessionButton.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 25..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class hRelatedSessionButton: UIButton {

    var session: Session? = nil
    let imgView: UIImageView
    let title: UILabel
    
    required init?(coder aDecoder: NSCoder) {
        self.imgView = UIImageView()
        self.title = UILabel()
        
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.black
        
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        title.numberOfLines = 3
        title.font = UIFont.systemFont(ofSize: 10)
        title.textColor = UIColor.darkGray
        
        imgView.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(imgView)
        self.addSubview(title)
        
        let views = ["title": title, "image": imgView] as [String : Any]
        let ratio = 16.0 / 9.0
        let height = frame.size.width / CGFloat(ratio)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[image(<=\(frame.size.width))]|",
            options: .alignAllFirstBaseline,
            metrics: nil,
            views: views)
        )
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[title(<=\(frame.size.width))]-|",
            options: .alignAllTop,
            metrics: nil,
            views: views)
        )
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[image(==\(height))][title]-|",
            options: .alignAllCenterX,
            metrics: nil,
            views: views)
        )
    }
    
    func update(session: Session) {
        self.session = session
        
        self.title.text = session.title
        self.title.sizeToFit()
        
        ImageDownloadService.shared.get(url: session.image, filter: nil) { (res) in
            self.imgView.image = res.result.value
        }
    }
}
