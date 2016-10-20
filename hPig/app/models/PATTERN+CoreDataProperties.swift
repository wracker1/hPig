//
//  PATTERN+CoreDataProperties.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 20..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreData


extension PATTERN {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PATTERN> {
        return NSFetchRequest<PATTERN>(entityName: "PATTERN");
    }

    @NSManaged public var english: String?
    @NSManaged public var image: String?
    @NSManaged public var info: String?
    @NSManaged public var korean: String?
    @NSManaged public var mean: String?
    @NSManaged public var part: String?
    @NSManaged public var position: String?
    @NSManaged public var regdt: NSDate?
    @NSManaged public var title: String?
    @NSManaged public var uid: String?
    @NSManaged public var vid: String?
    @NSManaged public var svctype: String?
    @NSManaged public var channelId: String?
    @NSManaged public var channelImage: String?
    @NSManaged public var channelName: String?

}
