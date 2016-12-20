//
//  hProduct.swift
//  hPig
//
//  Created by Jesse on 2016. 11. 1..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

struct hPass: ResponseObjectSerializable, ResponseCollectionSerializable, CustomStringConvertible {
    
    let id: String
    let name: String
    let value: String
    let passType: String?
    
    var description: String {
        return "hProduct"
    }
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any],
            let id = representation["id"] as? String,
            let name = representation["name"] as? String,
            let value = representation["value"] as? String
            
            else { return nil }
        
        self.id = id
        self.name = name
        self.value = value
        self.passType = representation["passType"] as? String
        
    }
    
    init?(_ representation: Any) {
        guard
            let representation = representation as? [String: Any],
            let id = representation["id"] as? String,
            let name = representation["name"] as? String,
            let value = representation["value"] as? String
            
            else { return nil }
        
        self.id = id
        self.name = name
        self.value = value
        self.passType = representation["passType"] as? String
    }
    
    init(id: String, name: String, value: String, passType: String?) {
        self.id = id
        self.name = name
        self.value = value
        self.passType = passType
    }
    
    func tubePassType() -> String {
        if let type = passType {
            return type
        } else {
            let regex = try! NSRegularExpression(pattern: "(^[\\d]+).*?$", options: .caseInsensitive)
            let match = regex.firstMatch(in: id, options: .reportProgress, range: NSMakeRange(0, id.characters.count))!
            let range = match.rangeAt(1)
            let month = (id as NSString).substring(with: range)
            return "C0_\(month)"
        }
    }
}
