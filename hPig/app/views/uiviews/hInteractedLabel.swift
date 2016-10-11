//
//  hInteractedLabel.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 9..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class hInteractedLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.isUserInteractionEnabled = true
        
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureRecognizer:))))
    }
    
    override var canBecomeFirstResponder: Bool { get { return true } }
    
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if action.description == "_define:" {
//            return true
//        } else {
//            return false
//        }
//    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let item = UIMenuItem(title: "단어 저장", action: #selector(self.saveWord))
        let menu = UIMenuController.shared
        menu.menuItems = [item]
        menu.setTargetRect(self.frame, in: self)
        menu.setMenuVisible(true, animated: true)
        
        self.becomeFirstResponder()
    }
    
    func saveWord() {
    
    }
}
