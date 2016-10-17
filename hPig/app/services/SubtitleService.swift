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
    
    func subtitleData(_ id: String, part: Int, completion: @escaping ([BasicStudy]) -> Void) {
        NetService.shared.get(path: "/svc/api/caption/\(id)/\(part)").responseString(completionHandler: { (res) in
            if let value = res.result.value {
                let data = self.matchesInStringWithRegex("((\\d+?):(\\d+?))\\n+?(.*)\\n+?(.*)\\n*?", string: value).map({ (result) -> (CMTime, String, String) in
                    /**
                     *   0 - 전체
                     *   1 - 시간
                     *   2 - 분
                     *   3 - 초
                     *   4 - 영어
                     *   5 - 한글
                     */
                    let str = value as NSString
                    let min = str.substring(with: result.rangeAt(2))
                    let sec = str.substring(with: result.rangeAt(3))
                    let time = TimeFormatService.shared.stringToCMTime(min: min, sec: sec)
                    let english = str.substring(with: result.rangeAt(4))
                    let korean = str.substring(with: result.rangeAt(5))
                    
                    return (time, english, korean)
                })
                
                let subtitles = data.enumerated().map({ (i: Int, element: (CMTime, String, String)) -> BasicStudy in
                    let start = element.0
                    let end = i + 1 < data.count ? data[i + 1].0 : data[data.count - 1].0
                    return BasicStudy(timeRange: CMTimeRange(start: start, end: end), english: element.1, korean: element.2)
                })
                
                completion(subtitles)
            }
            
        })
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
        if let index = (items.index { (item) -> Bool in
            if let range = rangeBlock(item) {
                return range.containsTime(time)
            } else {
                return false
            }
        }) {
            return index
        } else {
            return 0
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
