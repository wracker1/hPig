//
//  PatternStudy.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 25..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import AVFoundation

struct PatternStudy: ResponseObjectSerializable, ResponseCollectionSerializable, CustomStringConvertible {
    let startTime: String
    let endTime: String
    let english: String
    let korean: String
    let meaning: String
    let info: String
    
    var description: String {
        return "PatternStudy"
    }
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any],
            let startTime = representation["startTime"] as? String,
            let endTime = representation["endTime"] as? String,
            let english = representation["english"] as? String,
            let korean = representation["korean"] as? String,
            let meaning = representation["meaning"] as? String,
            let info = representation["info"] as? String
            
            else { return nil }
        
        self.startTime = startTime
        self.endTime = endTime
        self.english = english
        self.korean = korean
        self.meaning = meaning
        self.info = info
    }
    
    func timeRange() -> CMTimeRange? {
        if let start = TimeFormatService.shared.stringToCMTime(startTime),
            let end = TimeFormatService.shared.stringToCMTime(endTime) {
            let margin = CMTimeMakeWithSeconds(0.3, 600)
            return CMTimeRange(start: start - margin, end: end + margin)
        } else {
            return nil
        }
    }
}
