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
    private var data: WordData? = nil
    
    var sentence: String? = nil
    var desc: String? = nil
    var time: Float = 0
    var session: Session? = nil
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var pronunciationLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        LayoutService.shared.layoutXibViews(superview: self, nibName: "eng_dic_view_cell", viewLayoutBlock: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        LayoutService.shared.layoutXibViews(superview: self, nibName: "eng_dic_view", viewLayoutBlock: nil)
        
        setup()
    }
    
    private func setup() {
        closeButton.layer.borderWidth = 1.0
        closeButton.layer.borderColor = secondPointColor.cgColor
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

                    let pron = data.pronunciation as NSString
                    let regex = try! NSRegularExpression(pattern: "<[^>]*?>", options: .caseInsensitive)
                    let range = NSRange(location: 0, length: pron.length)
                    
                    self.wordLabel.text = data.word
                    self.meaningLabel.text = data.summary
                    
                    let pronunciation = regex.stringByReplacingMatches(
                        in: pron as String,
                        range: range,
                        withTemplate: "")
                    
                    self.pronunciationLabel.text = pronunciation.characters.count > 0 ? "[\(pronunciation)]" : ""
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
        if let item = self.data {
            ApiService.shared.wordSoundData(word: item, completion: { (res) in
                if let data = res {
                    DispatchQueue.main.async {
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
