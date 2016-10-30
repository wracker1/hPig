//
//  WORD+CoreDataClass.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 31..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreData


public class WORD: NSManagedObject {
    static func wordId(item: String) -> String {
        return item.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) ?? item
    }
    
    
    func mutating(data: WordData, uid: String, sentence: String?) {
        self.id = WORD.wordId(item: data.word)
        self.uid = uid
        self.word = data.word
        self.summary = data.summary
        self.pron = data.pronunciation
        self.pronfile = data.soundUrl
        self.sentence = sentence
        self.regdt = Date() as NSDate
    }
}
