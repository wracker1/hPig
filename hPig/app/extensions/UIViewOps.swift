//
//  UIViewOps.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 18..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import Toast_Swift
import CoreGraphics

extension UIView {
    func presentToast(_ message: String) {
        self.presentToast(message, completion: nil)
    }
    
    func presentToast(_ message: String, completion: (() -> Void)?) {
        do {
            let toast = try self.toastViewForMessage(message,
                                                     title: nil,
                                                     image: nil,
                                                     style: ToastManager.shared.style)
            
            let position = CGPoint(
                x: self.bounds.size.width / 2.0,
                y: (self.bounds.size.height - (toast.frame.size.height / 2.0)) - 200
            )

            let duration = 2.0
            self.makeToast(message, duration: duration, position: position)
            
            if let callback = completion {
                Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { (_) in
                    callback()
                })
            }
        } catch {}
    }
    
    func border(color: UIColor = secondPointColor, width: CGFloat = 1.0) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    func cornerRadiusly(_ radius: CGFloat = 4.0) {
        self.layer.cornerRadius = radius
    }
}
