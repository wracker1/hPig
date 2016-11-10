//
//  UIAlertControllerOps.swift
//  hPig
//
//  Created by Jesse on 2016. 11. 10..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

extension UIAlertController {
    private func className(item: Any) -> String {
        let mirror = Mirror(reflecting: item)
        return String(describing: mirror.subjectType)
    }
    
    private func search(_ item: UIView?, name: String) -> UIView? {
        if let view = item {
            return view.subviews.filter({ (v) -> Bool in
                return className(item: v) == name
            }).first
        } else {
            return nil
        }
    }
    
    func contentView() -> UIView {
        return self.view.subviews.first!
    }
    
    func alertControllerInterfaceActionGroupView() -> UIView? {
        return search(contentView(), name: "_UIAlertControllerInterfaceActionGroupView")
    }
    
    func itemView() -> UIView? {
        return alertControllerInterfaceActionGroupView()?.subviews.first
    }
    
    func dimmingKnockoutBackdropView() -> UIView? {
        return search(alertControllerInterfaceActionGroupView(), name: "_UIDimmingKnockoutBackdropView")
    }

    func interfaceActionGroupHeaderScrollView() -> UIScrollView? {
        // subview of itemview
        return search(itemView(), name: "_UIInterfaceActionGroupHeaderScrollView") as? UIScrollView
    }
    
    func interfaceActionRepresentationsSequenceView() -> UIView? {
        // subview of itemview
        return search(itemView(), name: "_UIInterfaceActionRepresentationsSequenceView")
    }
    
    func interfaceActionGroupHeaderScrollContentView() -> UIView? {
        return interfaceActionGroupHeaderScrollView()?.subviews.first
    }
    
    private func labels() -> [UILabel] {
        return interfaceActionGroupHeaderScrollContentView()?.subviews.filter { (item) -> Bool in
            return (item as? UILabel) != nil
            } as! [UILabel]
    }
    
    func titleLabel() -> UILabel? {
        return labels().first
    }
    
    func messageLabel() -> UILabel? {
        if labels().count > 1 {
            return labels()[1]
        } else {
            return nil
        }
    }
    
    func interfaceActionSeparatableSequenceView() -> UIView? {
        return search(interfaceActionRepresentationsSequenceView(), name: "_UIInterfaceActionSeparatableSequenceView")
    }
    
    func stackView() -> UIStackView? {
        return interfaceActionSeparatableSequenceView()?.subviews.first as? UIStackView
    }
}
