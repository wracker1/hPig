//
//  TubeUserInfo.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 20..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

class TubeUserInfo: NSObject, ResponseObjectSerializable {
    let id: String
    let studyTime: Double
    let visitCnt: String
    let passType: String
    let pushYn: String
    let onService: String
    let enddt: String?
    let gender: String?
    let age: String?
    let image: String?
    let lastvisitdt: String?
    let nickname: String?
    let regdt: String?
    let startdt: String?
    let token: String?
    
    required init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any],
            let id = representation["id"] as? String
            
            else { return nil }
        
        self.id = id
        self.studyTime = representation["studyTime"] as? Double ?? 0
        self.visitCnt = representation["visitCnt"] as? String ?? "0"
        self.passType = representation["passType"] as? String ?? "C0_0"
        self.pushYn = representation["pushYn"] as? String ?? "N"
        self.onService = representation["onService"] as? String ?? "N"
        self.enddt = representation["enddt"] as? String
        self.gender = representation["gender"] as? String
        self.age = representation["age"] as? String
        self.image = representation["image"] as? String
        self.lastvisitdt = representation["lastvisitdt"] as? String
        self.nickname = representation["nickname"] as? String
        self.regdt = representation["regdt"] as? String
        self.startdt = representation["startdt"] as? String
        self.token = representation["token"] as? String
    }
    
    public init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(forKey: "id") as? String
            , let studyTime = aDecoder.decodeObject(forKey: "studyTime") as? Double
            , let visitCnt = aDecoder.decodeObject(forKey: "visitCnt") as? String
            , let passType = aDecoder.decodeObject(forKey: "passType") as? String
            , let pushYn = aDecoder.decodeObject(forKey: "pushYn") as? String
            , let onService = aDecoder.decodeObject(forKey: "onService") as? String
            else {
                return nil
        }
        
        self.id = id
        self.studyTime = studyTime
        self.visitCnt = visitCnt
        self.passType = passType
        self.pushYn = pushYn
        self.onService = onService
        
        self.enddt = aDecoder.decodeObject(forKey: "enddt") as? String
        self.gender = aDecoder.decodeObject(forKey: "gender") as? String
        self.age = aDecoder.decodeObject(forKey: "age") as? String
        self.image = aDecoder.decodeObject(forKey: "image") as? String
        self.lastvisitdt = aDecoder.decodeObject(forKey: "lastvisitdt") as? String
        self.nickname = aDecoder.decodeObject(forKey: "nickname") as? String
        self.regdt = aDecoder.decodeObject(forKey: "regdt") as? String
        self.startdt = aDecoder.decodeObject(forKey: "startdt") as? String
        self.token = aDecoder.decodeObject(forKey: "token") as? String
    }
    
    init?(_ data: Data) {
        guard let user = NSKeyedUnarchiver.unarchiveObject(with: data) as? TubeUserInfo else {
            return nil
        }
        
        self.id = user.id
        self.studyTime = user.studyTime
        self.visitCnt = user.visitCnt
        self.passType = user.passType
        self.pushYn = user.pushYn
        self.onService = user.onService
        
        self.enddt = user.enddt
        self.gender = user.gender
        self.age = user.age
        self.image = user.image
        self.lastvisitdt = user.lastvisitdt
        self.nickname = user.nickname
        self.regdt = user.regdt
        self.startdt = user.startdt
        self.token = user.token
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(studyTime, forKey: "studyTime")
        aCoder.encode(visitCnt, forKey: "visitCnt")
        aCoder.encode(passType, forKey: "passType")
        aCoder.encode(pushYn, forKey: "pushYn")
        aCoder.encode(onService, forKey: "onService")
        
        aCoder.encode(enddt, forKey: "enddt")
        aCoder.encode(gender, forKey: "gender")
        aCoder.encode(age, forKey: "age")
        aCoder.encode(image, forKey: "image")
        aCoder.encode(lastvisitdt, forKey: "lastvisitdt")
        aCoder.encode(nickname, forKey: "nickname")
        aCoder.encode(regdt, forKey: "regdt")
        aCoder.encode(startdt, forKey: "startdt")
        aCoder.encode(token, forKey: "token")
    }
    
    func encode() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    
    var expireDate: Date? {
        get {
            if let endDate = enddt {
                let format = DateFormatter()
                format.dateFormat = "yyyy.MM.dd HH:mm:ss"
                return format.date(from: "\(endDate) 23:59:59")
            } else {
                return nil
            }
        }
    }
    
    var isActiveUser: Bool {
        get {
            if let date = expireDate {
                return Date() <= date
            } else {
                return false
            }
        }
    }
}
