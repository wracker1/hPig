//
//  hEnglishDictionaryView.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 18..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreData
import CoreGraphics
import AVFoundation

class hEnglishDictionaryView: UIView {

    private var data: WordData? = nil
    private var viewController: UIViewController? = nil
    private var videoPlayer: hYTPlayerView? = nil
    private var audioPlayer: AVAudioPlayer? = nil
    private var visible = false
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var pronunciationLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        LayoutService.shared.layoutXibViews(superview: self, nibName: "eng_dic_view_cell", viewLayoutBlock: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        LayoutService.shared.layoutXibViews(superview: self, nibName: "eng_dic_view", viewLayoutBlock: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 10.0
        
        if let button = self.confirmButton {
            button.addTarget(self, action: #selector(self.dismiss), for: .touchUpInside)
        }
    }
    
    func present(_ controller: UIViewController, data: WordData, videoPlayer: hYTPlayerView?) {
        self.viewController = controller
        self.videoPlayer = videoPlayer
        self.update(data: data) {
            let size = controller.view.bounds.size
            self.frame = CGRect(x: 0, y: size.height, width: size.width, height: 0)
            self.sizeToFit()
            
            if self.visible {
                self.positioning()
            } else {
                controller.view.addSubview(self)
                
                UIView.animate(withDuration: 0.3) {
                    self.positioning()
                    self.visible = true
                }
            }
        }
    }
    
    private func positioning() {
        if let controller = self.viewController {
            let size = controller.view.bounds.size
            var frame = self.frame
            frame.origin.y = size.height - self.bounds.size.height
            self.frame = frame
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        self.wordLabel.sizeToFit()
        self.meaningLabel.sizeToFit()
        self.pronunciationLabel.sizeToFit()
        
        let wordSize = wordLabel.bounds.size
        let meanLabelSize = meaningLabel.bounds.size
        let padding: CGFloat = 120
        let thatSize = CGSize(width: size.width, height: wordSize.height + meanLabelSize.height + padding)
        return thatSize
    }
    
    func update(data: WordData, completion: (() -> Void)?) {
        self.data = data
        
        AuthenticateService.shared.userId { (uid) in
            if let item = self.data {
                let req: NSFetchRequest<WORD> = WORD.fetchRequest()
                let wordId = WORD.wordId(item: item.word)
                let query = "uid = '\(uid)' AND id = '\(wordId)'"
                req.predicate = NSPredicate(format: query)
                
                CoreDataService.shared.select(request: req) { (items, error) in
                    let hasWord = items.count != 0
                    self.saveButton.setImage(UIImage(named: hasWord ? "btn_bookmark_enable" : "btn_bookmark_disable"), for: .normal)
                    
                    let regex = try! NSRegularExpression(pattern: "<\\/?daum:pron>", options: .caseInsensitive)
                    let range = NSRange(location: 0, length: data.pronunciation.characters.count)
                    
                    self.wordLabel.text = data.word
                    self.meaningLabel.text = data.summary
                    
                    let pronunciation = regex.stringByReplacingMatches(
                        in: data.pronunciation,
                        options: [],
                        range: range,
                        withTemplate: "")
                    
                    self.pronunciationLabel.text = "[\(pronunciation)]"
                    self.wordLabel.sizeToFit()
                    self.meaningLabel.sizeToFit()
                    self.pronunciationLabel.sizeToFit()
                    
                    if let callback = completion {
                        callback()
                    }
                }
            }
        }
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        if self.superview != nil && self.visible, let controller = viewController {
            let size = controller.view.bounds.size
            
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    var frame = self.frame
                    frame.origin.y = size.height
                    self.frame = frame
                },
                completion: { (finish) in
                    self.removeFromSuperview()
                    self.visible = false
                    
                    if let vPlayer = self.videoPlayer {
                        if vPlayer.playerState() == .paused {
                            vPlayer.playVideo()
                        }
                    }
            })
        }
    }

    @IBAction func playSound(_ sender: AnyObject) {
        if let item = self.data, let url = URL(string: item.soundUrl) {
            let req = URLRequest(url: url)
            
            NetService.shared.get(req: req).responseData(completionHandler: { (res) in
                print(res.description)
                
                if let data = res.result.value {
                    DispatchQueue.main.async {
                        if let vPlayer = self.videoPlayer {
                            vPlayer.pauseVideo()
                        }
                        
                        do {
                            self.audioPlayer = try AVAudioPlayer(data: data, fileTypeHint: AVFileTypeMPEGLayer3)
                            
                            if let player = self.audioPlayer {
                                player.volume = 1.0
                                player.prepareToPlay()
                                player.play()
                            }
                        } catch let error {
                            print("\(error)")
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func save(_ sender: AnyObject) {
        AuthenticateService.shared.userId { (uid) in
            if let item = self.data, let superview = self.superview {
                let req: NSFetchRequest<WORD> = WORD.fetchRequest()
                let wordId = WORD.wordId(item: item.word)
                let query = "uid = '\(uid)' AND id = '\(wordId)'"
                req.predicate = NSPredicate(format: query)
                
                CoreDataService.shared.select(request: req) { (items, error) in
                    let hasWord = items.count > 0
                    
                    if hasWord, let word = items.first {
                        CoreDataService.shared.delete(model: word)
                    } else {
                        let (desc, ctx) = CoreDataService.shared.entityDescription("word")
                        let word = WORD(entity: desc!, insertInto: ctx)
                        word.mutating(data: item, uid: uid)
                        superview.presentToast("저장 하였습니다.\n학습 정보에서 확인 해보세요.")
                    }
                    
                    CoreDataService.shared.save()
                    
                    self.saveButton.setImage(
                        UIImage(named: hasWord ? "btn_bookmark_disable" : "btn_bookmark_enable"),
                        for: .normal
                    )
                }
            }
        }
    }
}
