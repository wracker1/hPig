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
    let id: String
    let email: String?
    let nickname: String?
    let encId: String?
    let profileImage: String?
    let age: String?
    let gender: String?
    let name: String?
    let birthDay: String?
    let accountId: String?
    let loginType: LoginType
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(nickname, forKey: "nickname")
        aCoder.encode(encId, forKey: "encId")
        aCoder.encode(profileImage, forKey: "profileImage")
        aCoder.encode(age, forKey: "age")
        aCoder.encode(gender, forKey: "gender")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(birthDay, forKey: "birthDay")
        aCoder.encode(accountId, forKey: "accountId")
        aCoder.encode(loginType.rawValue, forKey: "loginType")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(forKey: "id") as? String else {
            return nil
        }
        
        self.id = id
        self.email = aDecoder.decodeObject(forKey: "email") as? String
        self.nickname = aDecoder.decodeObject(forKey: "nickname") as? String
        self.encId = aDecoder.decodeObject(forKey: "encId") as? String
        self.profileImage = aDecoder.decodeObject(forKey: "profileImage") as? String
        self.age = aDecoder.decodeObject(forKey: "age") as? String
        self.gender = aDecoder.decodeObject(forKey: "gender") as? String
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.birthDay = aDecoder.decodeObject(forKey: "birthDay") as? String
        self.accountId = aDecoder.decodeObject(forKey: "accountId") as? String
        if let value = aDecoder.decodeObject(forKey: "loginType") as? String {
            self.loginType = LoginType(rawValue: value) ?? .naver
        } else {
            self.loginType = .naver
        }
    }
    
    init?(data: Data, loginType: LoginType) {
        let xml = SWXMLHash.parse(data)
        
        guard let email = xml["data"]["response"]["email"].element?.text else {
            return nil
        }
        
        let items = email.components(separatedBy: "@")
        
        if items.count > 0 {
            self.id = items[0]
        } else {
            self.id = email
        }
        
        let ageRange = xml["data"]["response"]["age"].element?.text?.components(separatedBy: "-") ?? [String]()
        
        if ageRange.count > 0 {
            self.age = ageRange[0]
        } else {
            self.age = xml["data"]["response"]["age"].element?.text
        }

        self.email = email
        self.nickname = xml["data"]["response"]["nickname"].element?.text
        self.encId = xml["data"]["response"]["enc_id"].element?.text
        self.profileImage = xml["data"]["response"]["profile_image"].element?.text ?? "https://ssl.pstatic.net/static/pwe/address/nodata_33x33.gif"
        self.gender = xml["data"]["response"]["gender"].element?.text
        self.accountId = xml["data"]["response"]["id"].element?.text
        self.name = xml["data"]["response"]["name"].element?.text
        self.birthDay = xml["data"]["response"]["birthDay"].element?.text
        self.loginType = loginType
    }
    
    init?(data: [String: Any], loginType: LoginType) {
        guard let id = data["id"] as? String else {
            return nil
        }
        
        self.id = id
        self.email = data["email"] as? String
        self.nickname = data["name"] as? String
        self.encId = nil
        
        if let picture = data["picture"] as? [String: Any],
            let pictureData = picture["data"] as? [String: Any],
            let url = pictureData["url"] as? String {
            
            self.profileImage = url
        } else {
            self.profileImage = nil
        }
        
        if let ageRange = data["age_range"] as? [String: Any], let ageData = ageRange["min"] as? Int {
            self.age = "\(ageData)"
        } else {
            self.age = nil
        }
        
        self.gender = (data["gender"] as? String).map({ (v) -> String in
            return v.substring(range: NSRange(location: 0, length: 1)).uppercased()
        })
        
        self.name = data["name"] as? String
        self.birthDay = nil
        self.accountId = nil
        self.loginType = loginType
    }
    
    init?(_ koUser: KOUser) {
        guard let uid = koUser.id, let properties = koUser.properties as? [String : Any] else {
            return nil
        }

        self.id = "\(uid.intValue)"
        self.email = nil
        self.nickname = properties["nickname"] as? String
        self.encId = nil
        self.profileImage = properties["profile_image"] as? String
        self.age = nil
        self.gender = nil
        self.name = properties["nickname"] as? String
        self.birthDay = nil
        self.accountId = koUser.uuid
        self.loginType = .kakaoTalk
        
    }
}
