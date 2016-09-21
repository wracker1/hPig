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
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any],
            let caption = representation["caption"] as? String,
            let category = representation["category"] as? String,
            let categoryName = representation["categoryName"] as? String,
            let channelId = representation["channelId"] as? String,
            let channelImage = representation["channelImage"] as? String,
            let channelName = representation["channelName"] as? String,
            let sessionDescription = representation["description"] as? String,
            let duration = representation["duration"] as? String,
            let id = representation["id"] as? String,
            let image = representation["image"] as? String,
            let languages = representation["languages"] as? [String],
            let level = representation["level"] as? String,
            let part = representation["part"] as? String,
            let pattern = representation["pattern"] as? String,
            let pubdate = representation["pubdate"] as? String,
            let regdt = representation["regdt"] as? String,
            let status = representation["status"] as? String,
            let svctype = representation["svctype"] as? String,
            let title = representation["title"] as? String,
            let type = representation["type"] as? String,
            let viewcnt = representation["viewcnt"] as? String
        else { return nil }
        
        self.caption = caption
        self.category = category
        self.categoryName = categoryName
        self.channelId = channelId
        self.channelImage = channelImage
        self.channelName = channelName
        self.sessionDescription = sessionDescription
        self.duration = duration
        self.id = id
        self.image = image
        self.languages = languages
        self.level = level
        self.part = part
        self.pattern = pattern
        self.pubdate = pubdate
        self.regdt = regdt
        self.status = status
        self.svctype = svctype
        self.title = title
        self.type = type
        self.viewcnt = viewcnt
    }
}
