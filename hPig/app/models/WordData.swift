//
//  WordData.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 18..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

struct WordData: ResponseObjectSerializable, ResponseCollectionSerializable, CustomStringConvertible {
    let position: Int
    let pronunciation: String
    let soundUrl: String
    let summary: String
    let word: String
    
    var description: String {
        return "WordData"
    }
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any],
            let position = representation["position"] as? Int,
            let pronunciation = representation["pron"] as? String,
            let soundUrl = representation["pronFile"] as? String,
            let summary = representation["summary"] as? String,
            let word = representation["word"] as? String
            
            else { return nil }
        
        self.position = position
        self.pronunciation = pronunciation
        self.soundUrl = soundUrl
        self.summary = summary
        self.word = word
    }
    
    init?(_ data: WORD) {
        guard let word = data.word
            , let pron = data.pron
            , let soundUrl = data.pronfile
            , let summary = data.summary else {
            return nil
        }
        
        self.word = word
        self.summary = summary
        self.pronunciation = pron
        self.soundUrl = soundUrl
        self.position = 0
    }
}
