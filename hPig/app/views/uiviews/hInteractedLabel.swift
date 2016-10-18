//
//  hInteractedLabel.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 9..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import Alamofire

class hInteractedLabel: UILabel {
    
    var wordTapBlock: ((WordData) -> Void)? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    override var canBecomeFirstResponder: Bool { get { return true } }
    
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        let loc = recognizer.location(in: self)
        
        let textView = UITextView(frame: self.frame)
        textView.textContainerInset = UIEdgeInsetsMake(0, -0.5, 0, -0.5)
        textView.font = self.font
        textView.text = self.text
        
        if let pos = textView.closestPosition(to: loc),
            let range = textView.tokenizer.rangeEnclosingPosition(pos, with: .word, inDirection: 0),
            let text = textView.text(in: range),
            let callback = wordTapBlock {
            
            NetService.shared.getObject(path: "/svc/api/dictionary/\(text)", completionHandler: { (res: DataResponse<WordData>) in
                if let data = res.result.value {
                    callback(data)
                }
            })
        }
    }
}
