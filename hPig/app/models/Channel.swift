//
//  Channel.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 19..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

struct Channel: ResponseObjectSerializable, ResponseCollectionSerializable, CustomStringConvertible {
    let id: String
    let name: String
    let banner: String
    let desc: String
    let image: String
    let regdt: String
    let subCnt: String
    let videoCnt: String
    var videoList = [Session]()
    
    var description: String {
        return "Channel"
    }
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any],
            let id = representation["id"] as? String,
            let name = representation["name"] as? String,
            let banner = representation["banner"] as? String,
            let desc = representation["description"] as? String,
            let image = representation["image"] as? String,
            let regdt = representation["regdt"] as? String,
            let subCnt = representation["subCnt"] as? String,
            let videoCnt = representation["videoCnt"] as? String,
            let videoList = representation["videoList"] as? [Any]
            
            else { return nil }
        
        self.id = id
        self.name = name
        self.banner = banner
        self.image = image
        self.regdt = regdt
        self.desc = desc
        self.subCnt = subCnt
        self.videoCnt = videoCnt
        self.videoList = videoList.flatMap { (data) -> Session? in
            return Session(response: response, representation: data)
        }
    }
}
