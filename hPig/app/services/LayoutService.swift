//
//  LayoutService.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class LayoutService {
    static let shared: LayoutService = {
        let instance = LayoutService()
        return instance
    }()
    
    func loadNib(_ nibName: String, superview: UIView) {
        layoutXibView(superview: superview, nibName: nibName)
    }
    
    func layoutXibViews(superview: UIView, nibName: String, viewLayoutBlock: ((UIView) -> Void)?) {
        if let items = UINib(nibName: nibName, bundle: nil).instantiate(withOwner: superview, options: nil) as? [UIView] {
            items.forEach({ (view) in
                view.frame = superview.bounds
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                superview.addSubview(view)
                
                if let block = viewLayoutBlock {
                    block(view)
                }
            })
        }
    }
    
    func layoutXibView(superview: UIView, nibName: String) {
        self.layoutXibViews(superview: superview, nibName: nibName, viewLayoutBlock: nil)
    }
    
    func adjustContentSize(_ mainScroller: UIScrollView, subScroller: UIScrollView) {
        if subScroller.contentSize.height > 0 {
            var subScrollerFrame = subScroller.frame
            subScrollerFrame.size.height = subScroller.contentSize.height
            subScroller.frame = subScrollerFrame
            
            var contentSize = mainScroller.contentSize
            contentSize.height = subScrollerFrame.origin.y + subScrollerFrame.size.height
            mainScroller.contentSize = contentSize
        }
    }
}
