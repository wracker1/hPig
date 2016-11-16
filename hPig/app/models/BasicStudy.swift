//
//  BasicStudy.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 25..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import AVFoundation

struct BasicStudy: ResponseObjectSerializable, ResponseCollectionSerializable, CustomStringConvertible {
    let english: String
    let korean: String
    let startTime: String
    var endTime: String? = nil
    
    var description: String {
        return "BasicStudy"
    }
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any],
            let startTime = representation["startTime"] as? String,
            let korean = representation["korean"] as? String,
            let english = representation["english"] as? String
            
            else { return nil }
        
        self.startTime = startTime
        self.english = english
        self.korean = korean
    }
    
    func timeRange() -> CMTimeRange? {
        if let start = TimeFormatService.shared.stringToCMTime(startTime),
            let endString = endTime,
            let end = TimeFormatService.shared.stringToCMTime(endString) {
            
            return CMTimeRange(start: start, end: end)
        } else {
            return nil
        }
    }
}
