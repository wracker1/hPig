//
//  User.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 13..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import SWXMLHash

struct User {
    let email: String
    let nickname: String
    let encId: String
    let profileImage: String
    let age: String
    let gender: String
    let id: String
    let name: String
    let birthDay: String
    
    init?(data: Data) {
        let xml = SWXMLHash.parse(data)
        
        self.email = xml["data"]["response"]["email"].element?.text ?? ""
        self.nickname = xml["data"]["response"]["nickname"].element?.text ?? ""
        self.encId = xml["data"]["response"]["enc_id"].element?.text ?? ""
        self.profileImage = xml["data"]["response"]["profile_image"].element?.text ?? "https://ssl.pstatic.net/static/pwe/address/nodata_33x33.gif"
        self.age = xml["data"]["response"]["age"].element?.text ?? ""
        self.gender = xml["data"]["response"]["gender"].element?.text ?? ""
        self.id = xml["data"]["response"]["id"].element?.text ?? "guest"
        self.name = xml["data"]["response"]["name"].element?.text ?? ""
        self.birthDay = xml["data"]["response"]["birthDay"].element?.text ?? ""
    }
}
