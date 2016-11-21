//
//  hTabBarController.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 31..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreGraphics

class hTabBarController: UITabBarController, iRateDelegate {
    
    @IBOutlet var rateView: UIView!
    
    private let rateItem = iRate.sharedInstance()
    private var alertController: UIAlertController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Bundle.main.loadNibNamed("rate_view", owner: self, options: nil)
        
        rateItem?.onlyPromptIfLatestVersion = false
        rateItem?.previewMode = true
        rateItem?.delegate = self
        
        rateView.clipsToBounds = true
        rateView.layer.cornerRadius = 8.0
    }
    
    func iRateShouldPromptForRating() -> Bool {
        
        if let controller = presentController() {
            let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
            alert.view.addSubview(rateView)
            alert.view.translatesAutoresizingMaskIntoConstraints = false
            rateView.translatesAutoresizingMaskIntoConstraints = false
            
            let views: [String: Any] = ["view" : rateView]
            
            alert.view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-[view(<=280)]-|",
                options: .alignAllCenterY,
                metrics: nil,
                views: views))
            
            alert.view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[view]-|",
                options: .alignAllCenterX,
                metrics: nil,
                views: views))
            
            controller.present(alert, animated: true, completion: nil)
            
            self.alertController = alert
        }
        
        return false
    }
    
    private func presentController() -> UIViewController? {
        if let navigator = self.selectedViewController as? UINavigationController,
            let topViewController = navigator.topViewController {
            return topViewController
        } else {
            return nil
        }
    }
    
    @IBAction func rateNow(_ sender: Any) {
        if let controller = presentController() {
            rateItem?.ratedThisVersion = true
            rateItem?.openRatingsPageInAppStore()
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func rateLater(_ sender: Any) {
        if let controller = presentController() {
            rateItem?.lastReminded = Date()
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
