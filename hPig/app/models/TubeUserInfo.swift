//
//  TubeUserInfo.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 20..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

struct TubeUserInfo: ResponseObjectSerializable, ResponseCollectionSerializable, CustomStringConvertible {
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
    
    var description: String {
        return "TubeUserInfo"
    }
    
    init?(response: HTTPURLResponse, representation: Any) {
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
        self.image = representation["gender"] as? String
        self.lastvisitdt = representation["lastvisitdt"] as? String
        self.nickname = representation["nickname"] as? String
        self.regdt = representation["regdt"] as? String
        self.startdt = representation["startdt"] as? String
        self.token = representation["token"] as? String
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
