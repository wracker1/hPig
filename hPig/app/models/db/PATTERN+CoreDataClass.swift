//
//  PATTERN+CoreDataClass.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 2..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreData


public class PATTERN: NSManagedObject {
    func mutating(userId: String, session: Session, pattern: PatternStudy, position: Int) {        
        self.uid = userId
        self.vid = session.id
        self.part = session.part
        self.position = String(position)
        self.image = session.image
        self.title = session.title
        self.english = pattern.english
        self.korean = pattern.korean
        self.mean = pattern.meaning
        self.regdt = NSDate()
    }
}
