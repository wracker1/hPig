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
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
//        let item = UIMenuItem(title: "단어 저장", action: #selector(self.saveWord))
//        let menu = UIMenuController.shared
//        menu.menuItems = [item]
//        menu.setTargetRect(self.frame, in: self)
//        menu.setMenuVisible(true, animated: true)
//        
//        self.becomeFirstResponder()
        
//        if let text = englishSubLabel.text {
//            let textStorage = NSTextStorage(string: text)
//            let layoutManager = NSLayoutManager()
//            let textContainer = NSTextContainer(size: englishSubLabel.bounds.size)
//            
//            textContainer.lineFragmentPadding = 0
//            textStorage.addLayoutManager(layoutManager)
//            
//            var glyphRange = NSMakeRange(0, 0)
//            layoutManager.characterRange(forGlyphRange: NSMakeRange(0, text.characters.count), actualGlyphRange: &glyphRange)
//            
//            let glyphRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
//            
//            print("\(glyphRect)")
//            
//            let touchPoint = gestureRecognizer.location(ofTouch: 0, in: englishSubLabel)
//            
//            print("\(touchPoint)")
//        }
    }
    
    func saveWord() {
    
    }
}
