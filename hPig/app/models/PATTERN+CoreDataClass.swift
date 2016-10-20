//
//  PATTERN+CoreDataClass.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 20..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreData


public class PATTERN: NSManagedObject {
    func mutating(userId: String, session: Session, pattern: PatternStudy, position: Int) {
        self.vid = session.id
        self.part = session.part
        self.title = session.title
        self.image = session.image
        self.svctype = session.svctype
        self.channelId = session.channelId
        self.channelName = session.channelName
        self.channelImage = session.channelImage
        
        self.uid = userId
        self.position = String(position)
        self.english = pattern.english
        self.korean = pattern.korean
        self.mean = pattern.meaning
        self.info = pattern.info
        self.regdt = NSDate()
    }
}
