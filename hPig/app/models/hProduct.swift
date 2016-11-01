//
//  hProduct.swift
//  hPig
//
//  Created by Jesse on 2016. 11. 1..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

struct hProduct: ResponseObjectSerializable, ResponseCollectionSerializable, CustomStringConvertible {
    
    let id: String
    let name: String
    let value: String
    
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
        
    }
}
