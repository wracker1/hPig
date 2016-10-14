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
    
    @discardableResult func presentAlert(_ viewController: UIViewController, view: UIView, completion: (() -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: "SpeakingTube", message: nil, preferredStyle: .alert)
        return embed(viewController, alert: alert, view: view, completion: completion)
    }
    
    @discardableResult func presentActionSheet(_ viewController: UIViewController, view: UIView, completion: (() -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: "SpeakingTube", message: nil, preferredStyle: .actionSheet)
        return embed(viewController, alert: alert, view: view, completion: completion)
    }
    
    private func embed(_ viewController: UIViewController, alert: UIAlertController, view: UIView, completion: (() -> Void)?) -> UIAlertController {

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
