//
//  hInteractedLabel.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 9..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import Alamofire
import CoreGraphics

class hInteractedLabel: UILabel {
    
    weak var viewController: UIViewController? = nil
    weak var videoPlayer: hYTPlayerView? = nil
    
    var session: Session? = nil
    var desc: String? = nil
    
    private let englishDictionaryView = hEnglishDictionaryView(frame: CGRectZero)
    private let textView = UITextView(frame: CGRectZero)
    private let textViewInsets = UIEdgeInsetsMake(0.0, -5.0, 0.0, -5.0)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        self.addGestureRecognizer(gestureRecognizer)
        
        englishDictionaryView.closeButton.addTarget(self, action: #selector(self.dismiss), for: .touchUpInside)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override var canBecomeFirstResponder: Bool { get { return true } }
    
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        let loc = recognizer.location(in: self)
        
        videoPlayer?.pauseVideo()
        videoPlayer?.currentCMTime(completion: { (time) in
            let sec = TimeFormatService.shared.secondsFromCMTime(time: time)
            
            /*
            let attr = NSAttributedString(string: self.text!)
            let textStorage = NSTextStorage(attributedString: attr)
            let layoutManager = NSLayoutManager()
            textStorage.addLayoutManager(layoutManager)
            
            let textContainer = NSTextContainer(size: CGSize(width: self.frame.size.width, height: self.frame.size.height + 100))
            textContainer.lineFragmentPadding = 0
            textContainer.maximumNumberOfLines = self.numberOfLines
            textContainer.lineBreakMode = self.lineBreakMode
            
            layoutManager.addTextContainer(textContainer)
            let index = layoutManager.characterIndex(for: loc, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            
            print((attr.string as NSString).substring(from: index))
            */
            
            let sentence = self.text
            let desc = self.desc
            
            self.textView.frame = self.bounds
            self.textView.textContainerInset = self.textViewInsets
            self.textView.font = self.font
            self.textView.text = self.text
            self.textView.textAlignment = self.textAlignment
            
            if let pos = self.textView.closestPosition(to: loc),
                let range = self.textView.tokenizer.rangeEnclosingPosition(pos, with: .word, inDirection: 0),
                let text = self.textView.text(in: range),
                let controller = self.viewController {
                
                NetService.shared.getObject(path: "/svc/api/dictionary/\(text)", completionHandler: { (res: DataResponse<WordData>) in
                    if let data = res.result.value {
                        
                        self.present(viewController: controller,
                                     data: data,
                                     sentence: sentence,
                                     desc: desc,
                                     time: sec)
                    }
                })
            }
        })
    }
    
    private func present(viewController: UIViewController, data: WordData, sentence: String?, desc: String?, time: Float) {
        englishDictionaryView.sentence = sentence
        englishDictionaryView.desc = desc
        englishDictionaryView.session = session
        englishDictionaryView.time = time
        englishDictionaryView.update(data: data, completion: nil)
        
        let alert = AlertService.shared.actionSheet(englishDictionaryView, width: self.bounds.size.width, handleCancel: { (_) in
            self.videoPlayer?.playVideo()
        })
        
        alert.popoverPresentationController?.sourceView = self
        alert.popoverPresentationController?.sourceRect = self.frame

        viewController.present(alert, animated: true, completion: {
            self.englishDictionaryView.setNeedsLayout()
            self.englishDictionaryView.setNeedsUpdateConstraints()
        })
    }
    
    func dismiss() {
        if let controller = viewController {
            controller.dismiss(animated: true, completion: { 
                self.videoPlayer?.playVideo()
            })
        }
    }
}
