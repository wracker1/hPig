//
//  Session.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import AVFoundation

struct Session: ResponseObjectSerializable, ResponseCollectionSerializable, CustomStringConvertible {
    let id: String
    let part: String
    let channelId: String
    let svctype: String
    
    let channelImage: String?
    let caption: String?
    let category: String?
    let categoryName: String?
    let channelName: String?
    let sessionDescription: String?
    let duration: String?
    let image: String?
    let languages: [String]?
    let level: String?
    let pattern: String?
    let pubdate: String?
    let regdt: String?
    let status: String?
    let title: String?
    let type: String?
    let viewcnt: String?
    
    var description: String {
        return "Session"
    }
    
    init?(_ history: HISTORY) {
        guard
            let id = history.vid
            , let part = history.part
        else {
            return nil
        }
        
        self.id = id
        self.part = part
        self.svctype = history.svctype ?? "F"
        self.image = history.image
        self.duration = history.duration
        self.status = history.status
        self.title = history.title
        self.channelId = history.channelId ?? ""
        self.channelImage = history.channelImage
        self.channelName = history.channelName
        
        self.caption = ""
        self.category = ""
        self.categoryName = ""
        self.sessionDescription = ""
        self.languages = nil
        self.level = ""
        self.pattern = ""
        self.pubdate = ""
        self.regdt = ""
        self.type = ""
        self.viewcnt = "0"
    }
    
    init?(_ pattern: PATTERN) {
        guard
            let id = pattern.vid
            , let part = pattern.part
            else {
                return nil
        }
        
        self.id = id
        self.part = part
        self.svctype = pattern.svctype ?? "F"
        self.image = pattern.image
        self.channelId = pattern.channelId ?? ""
        self.channelImage = pattern.channelImage
        self.channelName = pattern.channelName
        self.title = pattern.title
        
        self.duration = ""
        self.status = ""
        self.caption = ""
        self.category = ""
        self.categoryName = ""
        self.sessionDescription = ""
        self.languages = nil
        self.level = ""
        self.pattern = ""
        self.pubdate = ""
        self.regdt = ""
        self.type = ""
        self.viewcnt = "0"
    }
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any],
            let channelId = representation["channelId"] as? String,
            let id = representation["id"] as? String,
            let part = representation["part"] as? String,
            let svctype = representation["svctype"] as? String
        else { return nil }
        
        self.id = id
        self.part = part
        self.channelId = channelId
        self.svctype = svctype
        
        self.image = representation["image"] as? String
        self.caption = representation["caption"] as? String
        self.category = representation["category"] as? String
        self.categoryName = representation["categoryName"] as? String
        self.channelImage = representation["channelImage"] as? String
        self.channelName = representation["channelName"] as? String
        self.sessionDescription = representation["description"] as? String
        self.duration = representation["duration"] as? String ?? ""
        self.languages = representation["languages"] as? [String]
        self.level = representation["level"] as? String
        self.pattern = representation["pattern"] as? String
        self.pubdate = representation["pubdate"] as? String
        self.regdt = representation["regdt"] as? String
        self.status = representation["status"] as? String
        self.title = representation["title"] as? String
        self.type = representation["type"] as? String
        self.viewcnt = representation["viewcnt"] as? String
    }
    
    init?(id: String, part: String, channelId: String, svctype: String?) {
        self.id = id
        self.part = part
        self.channelId = channelId
        self.svctype = svctype ?? "F"
        
        self.image = nil
        self.caption = nil
        self.category = nil
        self.categoryName = nil
        self.channelImage = nil
        self.channelName = nil
        self.sessionDescription = nil
        self.duration = nil
        self.languages = nil
        self.level = nil
        self.pattern = nil
        self.pubdate = nil
        self.regdt = nil
        self.status = nil
        self.title = nil
        self.type = nil
        self.viewcnt = nil
    }
    
    var isFree: Bool {
        get {
            return svctype == "F"
        }
    }
    
    var durationTime: CMTime {
        get {
            let value = duration ?? "00:00"
            return TimeFormatService.shared.stringToCMTime(value)
        }
    }
}
