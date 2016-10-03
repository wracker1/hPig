//
//  HISTORY+CoreDataClass.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 3..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreData


public class HISTORY: NSManagedObject {
    func mutating(userId: String, session: Session, date: NSDate?, studyTime: Float) {
        self.uid = userId
        self.lastdate = date
        self.studytime = studyTime
        
        self.vid = session.id
        self.part = session.part
        self.title = session.title
        self.duration = session.duration
        self.image = session.image
        self.status = session.status
    }
}
