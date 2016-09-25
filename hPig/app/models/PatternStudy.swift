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
    
    func timeRange(_ timeScale: Int32?) -> CMTimeRange? {
        if let start = stringToTime(startTime, timeScale: timeScale), let end = stringToTime(endTime, timeScale: timeScale) {
            return CMTimeRange(start: start, end: end)
        } else {
            return nil
        }
    }
    
    private func stringToTime(_ value: String, timeScale: Int32?) -> CMTime? {
        let values = value.components(separatedBy: ":")
        
        if values.count > 1 {
            return TimeFormatService.shared.stringToCMTime(min: values[0], sec: values[1], timeScale: timeScale)
        } else {
            return nil
        }
    }
}
