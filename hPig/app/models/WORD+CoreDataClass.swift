//
//  WORD+CoreDataClass.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 19..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreData


public class WORD: NSManagedObject {
    static func wordId(item: String) -> String {
        return item.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) ?? item
    }
    
    func mutating(data: WordData, uid: String) {
        self.id = WORD.wordId(item: data.word)
        self.uid = uid
        self.word = data.word
        self.summary = data.summary
        self.pron = data.pronunciation
        self.pronfile = data.soundUrl
        self.regdt = Date() as NSDate
    }
}
