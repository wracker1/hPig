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
    
    func alert(_ view: UIView) -> UIAlertController {
        let alert = UIAlertController(title: "SpeakingTube", message: nil, preferredStyle: .alert)
        return embed(alert, view: view)
    }
    
    func actionSheet(_ view: UIView) -> UIAlertController {
        let alert = UIAlertController(title: "SpeakingTube", message: nil, preferredStyle: .actionSheet)
        return embed(alert, view: view)
    }
    
    func presentAlert(_ viewController: UIViewController, view: UIView, completion: (() -> Void)?) {
        let alert = UIAlertController(title: "SpeakingTube", message: nil, preferredStyle: .alert)
        
        embed(alert, view: view)
        
        viewController.present(alert, animated: true, completion: completion)
    }
    
    func presentActionSheet(_ viewController: UIViewController, view: UIView, completion: (() -> Void)?) {
        let alert = UIAlertController(title: "SpeakingTube", message: nil, preferredStyle: .actionSheet)
        
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
        
        view.clipsToBounds = true
        alert.view.clipsToBounds = true
        
        view.frame = alert.view.bounds
        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
        alert.view.addSubview(view)
        alert.view.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["view": view]
        let width = alert.view.bounds.size.width
        
        alert.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-[view(<=\(width)@1000)]-|",
                options: .alignAllCenterY,
                metrics: nil,
                views: views))
        
        alert.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[view]-(65)-|",
                options: .alignAllCenterX,
                metrics: nil,
                views: views))
        
        return alert
    }
}
