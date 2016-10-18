//
//  WORD+CoreDataClass.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 2..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreData


public class WORD: NSManagedObject {
    
    func mutating(data: WordData, uid: String) {
        self.uid = uid
        self.word = data.word
        self.summary = data.summary
        self.pron = data.pronunciation
        self.pronfile = data.soundUrl
        self.regdt = Date() as NSDate
    }
}
