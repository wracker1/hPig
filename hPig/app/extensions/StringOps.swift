//
//  StringOps.swift
//  hPig
//
//  Created by Jesse on 2016. 11. 18..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

extension String {
    func r() -> NSRegularExpression {
        return try! NSRegularExpression(pattern: self, options: .caseInsensitive)
    }
    
    func range() -> NSRange {
        return NSRange(location: 0, length: self.characters.count)
    }
    
    func substring(range: NSRange) -> String {
        return (self as NSString).substring(with: range)
    }
}
