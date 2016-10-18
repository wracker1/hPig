//
//  hEnglishDictionaryView.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 18..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class hEnglishDictionaryView: UIView {

    private var data: WordData? = nil
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var pronunciationLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        XibService.shared.layoutXibViews(superview: self, nibName: "eng_dic_view", viewLayoutBlock: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        XibService.shared.layoutXibViews(superview: self, nibName: "eng_dic_view", viewLayoutBlock: nil)
    }
    
    func update(data: WordData) {
        self.data = data
        
        let regex = try! NSRegularExpression(pattern: "<\\/?daum:pron>", options: .caseInsensitive)
        let range = NSRange(location: 0, length: data.pronunciation.characters.count)
        
        wordLabel.text = data.word
        meaningLabel.text = data.summary
        pronunciationLabel.text = regex.stringByReplacingMatches(
            in: data.pronunciation,
            options: [],
            range: range,
            withTemplate: "")
    }

    @IBAction func playSound(_ sender: AnyObject) {
        if let item = self.data, let url = URL(string: item.soundUrl) {
            let req = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
            
            NetService.shared.get(req: req).responseData(completionHandler: { (res) in
                if let data = res.result.value {
                    do {
                        let player = try AVAudioPlayer(data: data, fileTypeHint: AVFileTypeMPEGLayer3)
                        player.volume = 1.0
                        player.prepareToPlay()
                        player.play()
                    } catch let error {
                        print("\(error)")
                    }
                }
            })
        }
    }
    
    @IBAction func save(_ sender: AnyObject) {
        AuthenticateService.shared.userId { (uid) in
            if let item = self.data, let superview = self.superview {
                let req: NSFetchRequest<WORD> = WORD.fetchRequest()
                let query = "uid = '\(uid)' AND word = '\(item.word)'"
                req.predicate = NSPredicate(format: query)
                
                CoreDataService.shared.select(request: req) { (items, error) in
                    if items.count == 0 {
                        let (desc, ctx) = CoreDataService.shared.entityDescription("word")
                        let word = WORD(entity: desc!, insertInto: ctx)
                        word.mutating(data: item, uid: uid)
                        CoreDataService.shared.save()
                        
                        superview.presentToast("저장 하였습니다.\n학습 정보에서 확인 해보세요.")
                    }
                }
            }
        }
    }
}
