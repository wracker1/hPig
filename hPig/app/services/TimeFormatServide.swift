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
        let total = secondsFromCMTime(time: time)
        let min = String(format: "%02d", Int(total) / 60)
        let sec = String(format: "%02d", Int(total) % 60)
        return "\(min):\(sec)"
    }
    
    private func substringTime(string: String, range: NSRange) -> String {
        if range.length > 0 {
            return string.substring(range: range)
        } else {
            return "00"
        }
    }
    
    func stringToCMTime(_ timeString: String) -> CMTime? {
        let regex = "^(\\d*):(\\d*)([\\.\\:](\\d*))?$".r()
        if let matche: NSTextCheckingResult = regex.firstMatch(in: timeString, options: .reportProgress, range: timeString.range()) {
            let min = Float(substringTime(string: timeString, range: matche.rangeAt(1))) ?? 0
            let sec = Float(substringTime(string: timeString, range: matche.rangeAt(2))) ?? 0
            let millisec = Float(substringTime(string: timeString, range: matche.rangeAt(4))) ?? 0
            let total = Float64((min * 60) + sec + (millisec * 0.01))
            return CMTimeMakeWithSeconds(total, 600)
        } else {
            return nil
        }
    }
}
