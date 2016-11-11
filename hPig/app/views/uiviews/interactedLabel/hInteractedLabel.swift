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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        self.addGestureRecognizer(gestureRecognizer)
        
        englishDictionaryView.layer.cornerRadius = 10.0
        englishDictionaryView.clipsToBounds = true
        englishDictionaryView.confirmButton.addTarget(self, action: #selector(self.dismiss), for: .touchUpInside)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override var canBecomeFirstResponder: Bool { get { return true } }
    
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        videoPlayer?.pauseVideo()
        
        let time = videoPlayer?.currentTime() ?? 0
        let loc = recognizer.location(in: self)
        let textView = UITextView(frame: self.bounds)
        let sentence = self.text
        let desc = self.desc
        
        textView.textContainerInset = UIEdgeInsetsMake(0.0, -5.0, 0.0, -5.0)
        textView.font = self.font
        textView.text = self.text
        textView.textAlignment = self.textAlignment
        
        if let pos = textView.closestPosition(to: loc),
            let range = textView.tokenizer.rangeEnclosingPosition(pos, with: .word, inDirection: 0),
            let text = textView.text(in: range),
            let controller = viewController {
            
            NetService.shared.getObject(path: "/svc/api/dictionary/\(text)", completionHandler: { (res: DataResponse<WordData>) in
                if let data = res.result.value {
                    
                    self.present(viewController: controller,
                                 data: data,
                                 sentence: sentence,
                                 desc: desc,
                                 time: time)
                }
            })
            
        }
    }
    
    private func present(viewController: UIViewController, data: WordData, sentence: String?, desc: String?, time: Float) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "", style: .cancel, handler: { (_) in
            self.videoPlayer?.playVideo()
        }))
            
        alert.view.addSubview(englishDictionaryView)
        AlertService.shared.setupConstraints(englishDictionaryView, width: alert.view.bounds.size.width - 20)
        
        englishDictionaryView.sentence = sentence
        englishDictionaryView.desc = desc
        englishDictionaryView.session = session
        englishDictionaryView.time = time
        englishDictionaryView.update(data: data, completion: nil)

        viewController.present(alert, animated: true, completion: nil)
    }
    
    func dismiss() {
        if let controller = viewController {
            controller.dismiss(animated: true, completion: { 
                self.videoPlayer?.playVideo()
            })
        }
    }
}
