//
//  AlertService.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 13..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

class AlertService {
    static let shared: AlertService = {
        let instance = AlertService()
        return instance
    }()
    
    func presentAlert(_ viewController: UIViewController, view: UIView, completion: (() -> Void)?) {
        let alert = UIAlertController(title: "SpeakingTube", message: nil, preferredStyle: .alert)
        embed(viewController, alert: alert, view: view, completion: completion)
    }
    
    func presentActionSheet(_ viewController: UIViewController, view: UIView, completion: (() -> Void)?) {
        let alert = UIAlertController(title: "SpeakingTube", message: nil, preferredStyle: .actionSheet)
        embed(viewController, alert: alert, view: view, completion: completion)
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
    
    @discardableResult private func embed(_ viewController: UIViewController, alert: UIAlertController, view: UIView, completion: (() -> Void)?) -> UIAlertController {
        alert.addAction(UIAlertAction(title: "", style: .cancel, handler: nil))
        alert.view.addSubview(view)
        alert.view.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["view": view]
        let width = viewController.view.bounds.width
        
        alert.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-[view(<=\(width)@1000)]-|",
                options: .alignAllCenterY,
                metrics: nil,
                views: views))
        
        alert.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[view]-|",
                options: .alignAllCenterX,
                metrics: nil,
                views: views))
        
        viewController.present(alert, animated: true) {
            if let callback = completion {
                callback()
            }
        }
        
        return alert
    }
}
