//
//  Category.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

struct Category: ResponseObjectSerializable, ResponseCollectionSerializable, CustomStringConvertible {
    let id: String
    let name: String
    
    var description: String {
        return "Category"
    }
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any],
            let id = representation["id"] as? String,
            let name = representation["name"] as? String
        
            else { return nil }
        
        self.id = id
        self.name = name
    }
}
