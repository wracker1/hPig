//
//  WORD+CoreDataClass.swift
//  hPig
//
//  Created by 이동현 on 2016. 11. 1..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreData


public class WORD: NSManagedObject {
    static func wordId(item: String) -> String {
        return item.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) ?? item
    }
    
    
    func mutating(data: WordData, uid: String, sentence: String?, desc: String?, session: Session?, time: Float) {
        self.id = WORD.wordId(item: data.word)
        self.uid = uid
        self.word = data.word
        self.summary = data.summary
        self.pron = data.pronunciation
        self.pronfile = data.soundUrl
        self.sentence = sentence
        self.korean = desc
        self.regdt = Date() as NSDate
        self.time = time
        
        if let item = session {
            self.vid = item.id
            self.part = item.part
            self.svctype = item.svctype
            self.image = item.image
            self.title = item.title
            self.channelId = item.channelId
            self.channelName = item.channelName
            self.channelImage = item.channelImage
            self.duration = item.duration
        }
    }
}
