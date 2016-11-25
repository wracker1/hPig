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
    @IBOutlet var customTabBar: UIView!
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var homeLabel: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var bookmarkLabel: UIButton!
    @IBOutlet weak var myInfoButton: UIButton!
    @IBOutlet weak var myInfoLabel: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var settingLabel: UIButton!
    
    func buttons() -> [UIButton] {
        return [homeButton, bookmarkButton, myInfoButton, settingButton]
    }
    
    func labels() -> [UIButton] {
        return [homeLabel, bookmarkLabel, myInfoLabel, settingLabel]
    }
    
    private let activeButtonImages: [UIImage] = {
        let home = #imageLiteral(resourceName: "tab_home_sel")
        let bookmark = #imageLiteral(resourceName: "tab_book_sel")
        let myInfo = #imageLiteral(resourceName: "tab_my_sel")
        let setting = #imageLiteral(resourceName: "tab_set_sel")
        return [home, bookmark, myInfo, setting]
    }()
    
    private let deactiveButtonImages: [UIImage] = {
        let home = #imageLiteral(resourceName: "tab_home_non")
        let bookmark = #imageLiteral(resourceName: "tab_book_non")
        let myInfo = #imageLiteral(resourceName: "tab_my_non")
        let setting = #imageLiteral(resourceName: "tab_set_non")
        return [home, bookmark, myInfo, setting]
    }()
    
    private let rateItem = iRate.sharedInstance()
    private var presentItem: UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Bundle.main.loadNibNamed("tab_bar", owner: self, options: nil)
        Bundle.main.loadNibNamed("rate_view", owner: self, options: nil)
        
        setupTabbar()
        
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
        
        select(at: 0)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        customTabBar.frame = tabBar.frame
    }
    
    private func setupTabbar() {
        customTabBar.frame = tabBar.frame
        
        self.view.addSubview(customTabBar)
        
        homeButton.addTarget(self, action: #selector(self.didSelectHome(_:)), for: .touchUpInside)
        homeLabel.addTarget(self, action: #selector(self.didSelectHome(_:)), for: .touchUpInside)
        
        bookmarkButton.addTarget(self, action: #selector(self.didSelectBookmark(_:)), for: .touchUpInside)
        bookmarkLabel.addTarget(self, action: #selector(self.didSelectBookmark(_:)), for: .touchUpInside)
        
        myInfoButton.addTarget(self, action: #selector(self.didSelectMyInfo(_:)), for: .touchUpInside)
        myInfoLabel.addTarget(self, action: #selector(self.didSelectMyInfo(_:)), for: .touchUpInside)
        
        settingButton.addTarget(self, action: #selector(self.didSelectSetting(_:)), for: .touchUpInside)
        settingLabel.addTarget(self, action: #selector(self.didSelectSetting(_:)), for: .touchUpInside)
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
    
    func didSelectHome(_ sender: Any) {
        select(at: 0)
    }
    
    func didSelectBookmark(_ sender: Any) {
        select(at: 1)
        
    }
    
    func didSelectMyInfo(_ sender: Any) {
        select(at: 2)
    }
    
    func didSelectSetting(_ sender: Any) {
        select(at: 3)
    }
    
    private func select(at index: Int) {
        
        if index == selectedIndex, let navigator = selectedViewController as? UINavigationController {
            if navigator.viewControllers.count > 1 {
                navigator.popViewController(animated: true)
            } else {
                navigator.setNavigationBarHidden(false, animated: false)
            }
            
        }
        
        self.selectedIndex = index
        
        buttons().enumerated().forEach { (i, button) in
            if i == index {
                button.setImage(activeButtonImages[i], for: .normal)
            } else {
                button.setImage(deactiveButtonImages[i], for: .normal)
            }
        }
        
        labels().enumerated().forEach { (i, button) in
            if i == index {
                button.titleLabel?.textColor = RGBA(252, g: 26, b: 38, a: 1)
            } else {
                button.titleLabel?.textColor = RGBA(146, g: 146, b: 146, a: 1)
            }
        }
    }
}
