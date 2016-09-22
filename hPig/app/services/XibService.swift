//
//  XibService.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class XibService {
    static let shared: XibService = {
        let instance = XibService()
        return instance
    }()
    
    func layoutXibViews(superview: UIView, nibName: String, viewLayoutBlock: @escaping (UIView) -> Void) {
        if let items = UINib(nibName: nibName, bundle: nil).instantiate(withOwner: superview, options: nil) as? [UIView] {
            items.forEach({ (view) in
                
                view.translatesAutoresizingMaskIntoConstraints = false
                superview.addSubview(view)
                
                let data = ["view": view]
                
                superview.addConstraints(
                    NSLayoutConstraint.constraints(
                        withVisualFormat: "H:|[view]|",
                        options: .alignAllCenterY,
                        metrics: nil,
                        views: data
                    )
                )
                
                superview.addConstraints(
                    NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|[view]|",
                        options: .alignAllCenterX,
                        metrics: nil,
                        views: data
                    )
                )
                
                viewLayoutBlock(view)
            })
        }
    }
}
