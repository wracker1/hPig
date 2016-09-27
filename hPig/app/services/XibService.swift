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
                view.frame = superview.bounds
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                superview.addSubview(view)
                
                viewLayoutBlock(view)
            })
        }
    }
}
