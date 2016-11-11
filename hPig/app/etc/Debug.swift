//
//  Debug.swift
//  hPig
//
//  Created by Jesse on 2016. 11. 11..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

func traceView(_ view: UIView?, depth: Int = 0, find: ((Int, UIView) -> Void)? = nil) {
    view?.subviews.forEach({ (item) in
        let nextDepth = depth + 1
        
        if let callback = find {
            callback(nextDepth, item)
        }
        
        traceView(item, depth: nextDepth, find: find)
    })
}
