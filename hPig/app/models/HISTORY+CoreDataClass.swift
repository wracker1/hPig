//
//  HISTORY+CoreDataClass.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 25..
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
        self.svctype = session.svctype
        self.channelId = session.channelId
        self.channelImage = session.channelImage
        self.channelName = session.channelName
        
        self.uid = userId
        self.lastdate = date
        self.studytime = studyTime
        self.maxposition = Int64(maxPosition)
        
        let newPosition = Int64(position)
        
        if self.position <  newPosition {
            self.position = newPosition
        }
    }
}
