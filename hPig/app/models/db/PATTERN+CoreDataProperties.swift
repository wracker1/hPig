//
//  PATTERN+CoreDataProperties.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 2..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreData


extension PATTERN {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PATTERN> {
        return NSFetchRequest<PATTERN>(entityName: "PATTERN");
    }

    @NSManaged public var uid: String?
    @NSManaged public var vid: String?
    @NSManaged public var part: String?
    @NSManaged public var position: String?
    @NSManaged public var image: String?
    @NSManaged public var title: String?
    @NSManaged public var english: String?
    @NSManaged public var korean: String?
    @NSManaged public var regdt: NSDate?
    @NSManaged public var mean: String?

}
