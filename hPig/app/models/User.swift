//
//  User.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 13..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import SWXMLHash

class User: NSObject, NSCoding {
    let email: String?
    let nickname: String?
    let encId: String?
    let profileImage: String?
    let age: String?
    let gender: String?
    let name: String?
    let birthDay: String?
    let accountId: String?
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(email, forKey: "email")
        aCoder.encode(nickname, forKey: "nickname")
        aCoder.encode(encId, forKey: "encId")
        aCoder.encode(profileImage, forKey: "profileImage")
        aCoder.encode(age, forKey: "age")
        aCoder.encode(gender, forKey: "gender")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(birthDay, forKey: "birthDay")
        aCoder.encode(accountId, forKey: "accountId")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let email = aDecoder.decodeObject(forKey: "email") as? String else {
            return nil
        }
        
        self.email = email
        self.nickname = aDecoder.decodeObject(forKey: "nickname") as? String
        self.encId = aDecoder.decodeObject(forKey: "encId") as? String
        self.profileImage = aDecoder.decodeObject(forKey: "profileImage") as? String
        self.age = aDecoder.decodeObject(forKey: "age") as? String
        self.gender = aDecoder.decodeObject(forKey: "gender") as? String
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.birthDay = aDecoder.decodeObject(forKey: "birthDay") as? String
        self.accountId = aDecoder.decodeObject(forKey: "accountId") as? String
    }
    
    init?(data: Data) {
        let xml = SWXMLHash.parse(data)
        
        self.email = xml["data"]["response"]["email"].element?.text
        self.nickname = xml["data"]["response"]["nickname"].element?.text
        self.encId = xml["data"]["response"]["enc_id"].element?.text
        self.profileImage = xml["data"]["response"]["profile_image"].element?.text ?? "https://ssl.pstatic.net/static/pwe/address/nodata_33x33.gif"
        self.age = xml["data"]["response"]["age"].element?.text
        self.gender = xml["data"]["response"]["gender"].element?.text
        self.accountId = xml["data"]["response"]["id"].element?.text
        self.name = xml["data"]["response"]["name"].element?.text
        self.birthDay = xml["data"]["response"]["birthDay"].element?.text
    }
    
    var id: String {
        get {
            if let emailItem = email {
                let items = emailItem.components(separatedBy: "@")
                
                switch items.count {
                case 1, 2:
                    return items[0]
                default:
                    return kGuestId
                }
            } else {
                return kGuestId
            }
        }
    }
}
