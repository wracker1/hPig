//
//  APIService.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 19..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

class APIService {
    
    static let shared: APIService = {
        let instance = APIService()
        
        return instance
    }()
    
    var user: User? = nil
    
    func shouldPerform(_ id: String, session: Session?) -> Bool {
        switch id {
        case "showSessionMain":
            let shouldPerform = true
            
            return shouldPerform
        default:
            return false
        }
    }
}
