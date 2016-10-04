//
//  HISTORY+CoreDataClass.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 4..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreData


public class HISTORY: NSManagedObject {
    func mutating(userId: String, session: Session, date: NSDate?, studyTime: Float, position: Int, maxPosition: Int) {
        self.vid = session.id
        self.part = session.part
        self.title = session.title
        self.duration = session.duration
        self.image = session.image
        self.status = session.status
        
        self.uid = userId
        self.lastdate = date
        self.studytime = studyTime
        self.maxposition = String(maxPosition)
        
        let old = Int(self.position ?? "0") ?? 0
        if old < position {
            self.position = String(position)
        }
    }
}
