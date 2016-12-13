//
//  Global.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 25..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import AVFoundation

let kToggleKoreanLabelVisible = Notification.Name("kToggleKoreanLabelVisible")
let kToggleEnglishLabelVisible = Notification.Name("kToggleEnglishLabelVisible")
let kSelectCellWithIndexPath = Notification.Name("kSelectRowWithIndexPath")
let kViewWillTransition = Notification.Name("viewWillTransition")
let kGuestId = "guest"
let kTokenKey = "deviceToken"
let kMaxPopoverViewWidth: CGFloat = 420

let preTimeMargin = CMTimeMakeWithSeconds(0.2, 600)
let postTimeMargin = CMTimeMakeWithSeconds(0.3, 600)

let SubtitlePointColor = RGBA(213, g: 135, b: 125, a: 1)

let pointColor = RGBA(246, g: 0, b: 29, a: 1)
let secondPointColor = RGBA(252, g: 86, b: 97, a: 1.0)

let CGRectZero = CGRectFromString("{{0, 0}, {0, 0}}")

func presentController(viewController: UIViewController) -> UIViewController? {
    if let tabBarController = viewController.navigationController?.presentingViewController as? hTabBarController,
        let navigationController = tabBarController.selectedViewController as? UINavigationController,
        let topViewController = navigationController.topViewController {
        
        return topViewController
    } else {
        return nil
    }
}

func RGBA(_ r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
}

func className(item: Any) -> String {
    let mirror = Mirror(reflecting: item)
    return String(describing: mirror.subjectType)
}

func search(_ item: UIView?, name: String) -> UIView? {
    if let view = item {
        return view.subviews.filter({ (v) -> Bool in
            return className(item: v) == name
        }).first
    } else {
        return nil
    }
}

func deepSearch(_ item: UIView, name: String) -> UIView? {
    if className(item: item) == name {
        return item
    } else {
        let results = item.subviews.flatMap({ (candidate) -> UIView? in
            return deepSearch(candidate, name: name)
        })
        
        return results.first
    }
}

func barButtonItem(_ imageNamed: String, size: CGSize, target: AnyObject?, selector: Selector) -> UIBarButtonItem {
    let btn = UIButton(type: .custom)
    btn.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    btn.setImage(UIImage(named: imageNamed), for: .normal)
    btn.addTarget(target, action: selector, for: .touchUpInside)
    return UIBarButtonItem(customView: btn)
}

func traverse(_ view: UIView?, depth: Int = 0, find: ((Int, UIView) -> Void)? = nil) {
    view?.subviews.forEach({ (item) in
        let nextDepth = depth + 1
        
        if let callback = find {
            callback(nextDepth, item)
        }
        
        traverse(item, depth: nextDepth, find: find)
    })
}
