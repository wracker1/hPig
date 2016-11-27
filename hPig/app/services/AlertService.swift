//
//  AlertService.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 13..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreGraphics

class AlertService {
    private let bottomMargin: CGFloat = 0
    private let horizontalMargin: CGFloat = 20
    
    static let shared: AlertService = {
        let instance = AlertService()
        return instance
    }()
    
    func alert(_ view: UIView, width: CGFloat) -> UIAlertController {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        return embed(alert, view: view, width: width)
    }
    
    func actionSheet(_ view: UIView, width: CGFloat, handleCancel: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: handleCancel))
        return embed(alert, view: view, width: width)
    }
    
    func confirm(_ viewController: UIViewController, title: String, message: String?, cancel: (() -> Void)?, confirm: (() -> Void)?) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (_) in
            viewController.dismiss(animated: true, completion: cancel)
        }))
        
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (_) in
            if let callback = confirm {
                callback()
            }
        }))
        
        return alert
    }
    
    @discardableResult private func embed(_ alert: UIAlertController, view: UIView, width: CGFloat) -> UIAlertController {
        
        alert.view.addSubview(view)
        setupConstraints(view, width: width)
        
        return alert
    }
    
    func setupConstraints(_ item: UIView?, width: CGFloat) {
        if let view = item, let target = view.superview {
            target.translatesAutoresizingMaskIntoConstraints = false
            view.translatesAutoresizingMaskIntoConstraints = false
            
            let views = ["view": view]
            
            target.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|[view(==\(width - horizontalMargin))]|",
                    options: .alignAllCenterY,
                    metrics: nil,
                    views: views))
            
            target.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-[view]-(\(bottomMargin))-|",
                    options: .alignAllCenterX,
                    metrics: nil,
                    views: views))
        }
    }
}
