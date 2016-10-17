//
//  TIME_LOG+CoreDataClass.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 17..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreData


public class TIME_LOG: NSManagedObject {
    func mutating(userId: String, vid: String, startTime: Date, type: String) {
        self.uid = userId
        self.vid = vid
        self.regdt = Date() as NSDate
        self.studytime = startTime.timeIntervalSinceNow * -1
        self.type = type
    }
}
