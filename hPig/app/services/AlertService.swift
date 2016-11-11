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
    static let shared: AlertService = {
        let instance = AlertService()
        return instance
    }()
    
    func alert(_ view: UIView) -> UIAlertController {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        return embed(alert, view: view)
    }
    
    func actionSheet(_ view: UIView, handleCancel: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: handleCancel))
        return embed(alert, view: view)
    }
    
    func presentAlert(_ viewController: UIViewController, view: UIView, completion: (() -> Void)?) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        embed(alert, view: view)
        
        viewController.present(alert, animated: true, completion: completion)
    }
    
    func presentActionSheet(_ viewController: UIViewController, view: UIView, completion: (() -> Void)?, handleCancel: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: handleCancel))
        embed(alert, view: view)
        
        viewController.present(alert, animated: true, completion: completion)
    }
    
    func presentConfirm(_ viewController: UIViewController, title: String, message: String?, cancel: (() -> Void)?, confirm: (() -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (_) in
            viewController.dismiss(animated: true, completion: cancel)
        }))
        
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (_) in
            if let callback = confirm {
                callback()
            }
        }))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    @discardableResult private func embed(_ alert: UIAlertController, view: UIView) -> UIAlertController {
        
        if let actionGroupView = alert.alertControllerInterfaceActionGroupView(),
            let target = alert.dimmingKnockoutBackdropView() {
            
            actionGroupView.backgroundColor = UIColor.white
            actionGroupView.layer.cornerRadius = 15.0
            target.addSubview(view)
            
            setupConstraints(view, width: alert.view.bounds.size.width)
        }
        
        return alert
    }
    
    func setupConstraints(_ item: UIView?, width: CGFloat) {
        if let view = item, let target = view.superview {
            target.translatesAutoresizingMaskIntoConstraints = false
            view.translatesAutoresizingMaskIntoConstraints = false
            
            let views = ["view": view]
            
            target.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-[view(==\(width)@750)]-|",
                    options: .alignAllCenterY,
                    metrics: nil,
                    views: views))
            
            target.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[view]|",
                    options: .alignAllCenterX,
                    metrics: nil,
                    views: views))
        }
    }
}
