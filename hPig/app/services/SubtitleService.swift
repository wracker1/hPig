//
//  SubtitleService.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 25..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import Alamofire
import AVFoundation

class SubtitleService {
    static let shared: SubtitleService = {
        let instance = SubtitleService()
        return instance
    }()
    
    func subtitleData(_ id: String, part: Int, duration: String?, completion: @escaping ([BasicStudy]) -> Void) {
        NetService.shared.getCollection(path: "/svc/api/v2/caption/\(id)/\(part)") { (res: DataResponse<[BasicStudy]>) in
            if let data = res.result.value {
                let basicData = data.enumerated().map({ (i, item) -> BasicStudy in
                    var sub = item
                    let next = data.get(i + 1)
                    sub.endTime = next == nil ? duration : next?.startTime
                    return sub
                })
                
                completion(basicData)
            }
        }
    }
    
    func patternStudyData(_ id: String, part: Int, completion: @escaping ([PatternStudy]) -> Void) {
        NetService.shared.getCollection(path: "/svc/api/v2/pattern/\(id)/\(part)") { (res: DataResponse<[PatternStudy]>) in
            if let data = res.result.value {
                completion(data)
            } else {
                completion([])
            }
        }
    }
    
    func currentIndex<T>(_ time: CMTime, items: [T], rangeBlock: (T) -> CMTimeRange?) -> Int {
        let opt = items.index { (item) -> Bool in
            if let range = rangeBlock(item) {
                return range.containsTime(time)
            } else {
                return false
            }
        }
        
        if let index = opt {
            return index
        } else {
            if let first = items.first,
                let last = items.last,
                let firstRange = rangeBlock(first),
                let lastRange = rangeBlock(last) {
                
                if time <= firstRange.start {
                    return 0
                } else if time >= lastRange.end {
                    return items.count - 1
                } else {
                    return -1
                }
            } else {
                return -1
            }
        }
    }
    
    func buildAttributedString(_ string: String) -> NSMutableAttributedString {
        let data = matchesInStringWithRegex("\\^(.*?)\\^", string: string).map { (result) -> NSRange in
            return result.rangeAt(1)
        }

        let replaced = string.replacingOccurrences(of: "^", with: "", options: .literal, range: nil)
        let attributedString = NSMutableAttributedString(string: replaced)
        
        data.forEach { (range) in
            attributedString.addAttributes(
                [NSForegroundColorAttributeName: SubtitlePointColor],
                range: NSRange(location: range.location - 1, length: range.length)
            )
        }
        
        return attributedString
    }
    
    private func matchesInStringWithRegex(_ regex: String, string: String) -> [NSTextCheckingResult] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: .caseInsensitive)
            return regex.matches(in: string, options: .reportProgress, range: NSMakeRange(0, string.characters.count))
        } catch {
            print(error)
            return []
        }
    }
}
