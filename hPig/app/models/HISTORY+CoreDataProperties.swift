//
//  HISTORY+CoreDataProperties.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 4..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreData


extension HISTORY {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HISTORY> {
        return NSFetchRequest<HISTORY>(entityName: "HISTORY");
    }

    @NSManaged public var duration: String?
    @NSManaged public var image: String?
    @NSManaged public var lastdate: NSDate?
    @NSManaged public var maxposition: String?
    @NSManaged public var part: String?
    @NSManaged public var position: String?
    @NSManaged public var status: String?
    @NSManaged public var studytime: Float
    @NSManaged public var title: String?
    @NSManaged public var uid: String?
    @NSManaged public var vid: String?

}
