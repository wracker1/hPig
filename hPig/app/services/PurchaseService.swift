//
//  PurchaseService.swift
//  hPig
//
//  Created by Jesse on 2016. 11. 1..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

class PurchaseService {
    static let shared: PurchaseService = {
        let instance = PurchaseService()
        return instance
    }()
    
    func data(_ completion: (() -> Void)?) {
//        NetService.shared.get(path: "/svc/api/purchase/ios/item")
    }
    
}
