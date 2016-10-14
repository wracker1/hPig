//
//  Global.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 25..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

struct Global {
    static let kToggleKoreanLabelVisible = Notification.Name("kToggleKoreanLabelVisible")
    static let kToggleEnglishLabelVisible = Notification.Name("kToggleEnglishLabelVisible")
    
    static let guestId = "guest"
}

func RGBA(_ r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
}

func barButtonItem(_ imageNamed: String, size: CGSize, target: AnyObject?, selector: Selector) -> UIBarButtonItem {
    let btn = UIButton(type: .custom)
    btn.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    btn.setImage(UIImage(named: imageNamed), for: .normal)
    btn.addTarget(target, action: selector, for: .touchUpInside)
    return UIBarButtonItem(customView: btn)
}

let SubtitlePointColor = RGBA(213, g: 135, b: 125, a: 1)

let CGRectZero = CGRectFromString("{{0, 0}, {0, 0}}")
