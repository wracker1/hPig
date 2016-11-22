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
    @IBOutlet weak var remindMeLaterButton: UIButton!
    
    private let rateItem = iRate.sharedInstance()
    private var presentItem: UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Bundle.main.loadNibNamed("rate_view", owner: self, options: nil)
        
        //rateItem?.previewMode = true
        rateItem?.onlyPromptIfLatestVersion = false
        rateItem?.delegate = self
        
        rateItem?.daysUntilPrompt = 3.0
        rateItem?.usesUntilPrompt = 15
        rateItem?.usesPerWeekForPrompt = 1.0
        
        rateView.clipsToBounds = true
        rateView.layer.cornerRadius = 8.0
        
        remindMeLaterButton.layer.borderWidth = 1.0
        remindMeLaterButton.layer.borderColor = RGBA(252, g: 86, b: 97, a: 1.0).cgColor
    }
    
    func iRateShouldPromptForRating() -> Bool {
        
        if let controller = presentController() {
            let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
            alert.view.addSubview(rateView)
            alert.view.translatesAutoresizingMaskIntoConstraints = false
            rateView.translatesAutoresizingMaskIntoConstraints = false
            
            let views: [String: Any] = ["view" : rateView]
            
            alert.view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-[view(<=290)]-|",
                options: .alignAllCenterY,
                metrics: nil,
                views: views))
            
            alert.view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[view]-|",
                options: .alignAllCenterX,
                metrics: nil,
                views: views))
            
            controller.present(alert, animated: true, completion: nil)
            self.presentItem = controller
            
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
        if let controller = presentItem {
            rateItem?.ratedThisVersion = true
            rateItem?.openRatingsPageInAppStore()
            
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func rateLater(_ sender: Any) {
        if let controller = presentItem {
            rateItem?.lastReminded = Date()
            
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func dontWantShowAgain(_ sender: Any) {
        if let controller = presentItem {
            rateItem?.declinedThisVersion = true
            
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
