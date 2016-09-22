//
//  OptionOps.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

extension Optional {
    func ifDefined(_ nonEmptyBlock: @escaping (Wrapped) -> Void) -> Void {
        if let item = self {
            nonEmptyBlock(item)
        }
    }
    
    func fold<T>(_ ifEmpty: @escaping () -> T, f: @escaping (Wrapped) -> T) -> T {
        if let v = self {
            return f(v)
        } else {
            return ifEmpty()
        }
    }
}
