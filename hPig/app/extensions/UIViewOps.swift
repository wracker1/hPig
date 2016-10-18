//
//  UIViewOps.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 18..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import Toast_Swift

extension UIView {
    func presentToast(_ message: String) {
        do {
            let toast = try self.toastViewForMessage(message,
                                                     title: nil,
                                                     image: nil,
                                                     style: ToastManager.shared.style)
            
            let position = CGPoint(
                x: self.bounds.size.width / 2.0,
                y: (self.bounds.size.height - (toast.frame.size.height / 2.0)) - 130
            )

            self.makeToast(message, duration: 2.0, position: position)
        } catch {}
    }
}
