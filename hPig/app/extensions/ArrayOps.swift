//
//  ArrayOps.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

extension Array {
    func get(_ i: Int) -> Optional<Element> {
        if i > -1 && i < self.count {
            return self[i]
        } else {
            return nil
        }
    }
    
    func find(_ search: (Element) -> Bool) -> Optional<Element> {
        var item: Optional<Element> = nil
        
        for elem in self {
            if search(elem) {
                item = elem
                break
            }
        }
        
        return item
    }
}
