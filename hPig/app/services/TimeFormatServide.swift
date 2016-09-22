//
//  TimeFormatServide.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import AVFoundation

class TimeFormatService {
    static let shared: TimeFormatService = {
        let instance = TimeFormatService()
        return instance
    }()
    
    func timeFromFloat(seconds: Float) -> CMTime {
        return CMTimeMakeWithSeconds(Float64(seconds), 600)
    }
    
    func secondsFromCMTime(time: CMTime) -> Float {
        return Float(CMTimeGetSeconds(time))
    }
    
    func timeStringFromCMTime(time: CMTime) -> String {
        let total = Int(secondsFromCMTime(time: time))
        let min = String(format: "%02d", total / 60)
        let sec = String(format: "%02d", total % 60)
        return "\(min):\(sec)"
    }
    
    func stringToCMTime(timeString: String) -> CMTime {
        let items = timeString.components(separatedBy: ":")
        switch items.count {
        case 1:
            let sec = Float(items[0])!
            return CMTimeMakeWithSeconds(Float64(sec), 600)
        case 2:
            let min = Float(items[0])! * 60.0
            let sec = Float(items[1])!
            return CMTimeMakeWithSeconds(Float64(min + sec), 600)
        default:
            return CMTimeMakeWithSeconds(Float64(0), 600)
        }
    }
    
    func stringToCMTime(min: String, sec: String, timeScale: Int32?) -> CMTime {
        return CMTimeMakeWithSeconds(Float64(min)! * 60 + Float64(sec)!, timeScale ?? 600)
    }
    
    func stringToCMTimeRange(startMin: String, startSec: String, endMin: String, endSec: String, timeScale: Int32?) -> CMTimeRange {
        return CMTimeRange(
            start: stringToCMTime(min: startMin, sec: startSec, timeScale: timeScale),
            end: stringToCMTime(min: endMin, sec: endSec, timeScale: timeScale)
        )
    }
}
