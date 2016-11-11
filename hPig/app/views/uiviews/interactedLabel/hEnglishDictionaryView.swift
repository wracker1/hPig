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

    private var audioPlayer: AVAudioPlayer? = nil
    private var sentence: String? = nil
    private var desc: String? = nil
    private var time: Float = 0
    private var data: WordData? = nil
    private var session: Session? = nil
    
    private weak var viewController: UIViewController? = nil
    private weak var videoPlayer: hYTPlayerView? = nil
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var pronunciationLabel: UILabel!
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
    }
    
    func present(_ controller: UIViewController,
                 data: WordData,
                 sentence: String?,
                 desc: String?,
                 session: Session?,
                 time: Float,
                 videoPlayer: hYTPlayerView?) {
        
        self.viewController = controller
        self.videoPlayer = videoPlayer
        self.sentence = sentence
        self.desc = desc
        self.session = session
        self.time = time
        
        self.update(data: data) {
            let alert = AlertService.shared.actionSheet(self, handleCancel: { (_) in
                self.videoPlayer?.playVideo()
            })
            
            controller.present(alert, animated: true, completion: {
                traceView(alert.view, find: { (depth, item) in
                    item.isUserInteractionEnabled = true
                    print("=========>\n\(item.isUserInteractionEnabled), \(item)\ndepth: \(depth)\nparent: \(item.superview)\n\n")
                })
            })
        }
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
                    
                    if hasWord, let word = items.get(0) {
                        word.count += 1
                        CoreDataService.shared.save()
                    }
                }
            }
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
                        word.mutating(data: item, uid: uid, sentence: self.sentence, desc: self.desc, session: self.session, time: self.time)
                        word.count += 1
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
