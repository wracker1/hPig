//
//  Session.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

struct Session: ResponseObjectSerializable, ResponseCollectionSerializable, CustomStringConvertible {
    let caption: String
    let category: String
    let categoryName: String
    let channelId: String
    let channelImage: String
    let channelName: String
    let sessionDescription: String
    let duration: String
    let id: String
    let image: String
    let languages: [String]?
    let level: String
    let part: String
    let pattern: String
    let pubdate: String
    let regdt: String
    let status: String
    let svctype: String
    let title: String
    let type: String
    let viewcnt: String
    
    var description: String {
        return "Session"
    }
    
    init?(_ history: HISTORY) {
        guard
            let id = history.vid
            , let part = history.part
            , let image = history.image
            , let title = history.title
            , let duration = history.duration
            , let status = history.status
        else {
            return nil
        }
        
        self.caption = ""
        self.category = ""
        self.categoryName = ""
        self.channelId = ""
        self.channelImage = ""
        self.channelName = ""
        self.sessionDescription = ""
        self.duration = duration
        self.id = id
        self.image = image
        self.languages = nil
        self.level = ""
        self.part = part
        self.pattern = ""
        self.pubdate = ""
        self.regdt = ""
        self.status = status
        self.svctype = ""
        self.title = title
        self.type = ""
        self.viewcnt = "0"
    }
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any],
            let channelId = representation["channelId"] as? String,
            let id = representation["id"] as? String,
            let image = representation["image"] as? String,
            let part = representation["part"] as? String,
            let svctype = representation["svctype"] as? String
        else { return nil }
        
        self.id = id
        self.image = image
        self.part = part
        self.svctype = svctype
        self.channelId = channelId
        
        self.caption = representation["caption"] as? String ?? ""
        self.category = representation["category"] as? String ?? ""
        self.categoryName = representation["categoryName"] as? String ?? ""
        self.channelImage = representation["channelImage"] as? String ?? ""
        self.channelName = representation["channelName"] as? String ?? ""
        self.sessionDescription = representation["description"] as? String ?? ""
        self.duration = representation["duration"] as? String ?? ""
        self.languages = representation["languages"] as? [String] ?? [String]()
        self.level = representation["level"] as? String ?? "1"
        self.pattern = representation["pattern"] as? String ?? ""
        self.pubdate = representation["pubdate"] as? String ?? ""
        self.regdt = representation["regdt"] as? String ?? ""
        self.status = representation["status"] as? String ?? "N"
        self.title = representation["title"] as? String ?? ""
        self.type = representation["type"] as? String ?? "video"
        self.viewcnt = representation["viewcnt"] as? String ?? "0"
    }
}
