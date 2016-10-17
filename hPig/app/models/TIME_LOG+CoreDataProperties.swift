//
//  TIME_LOG+CoreDataProperties.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 17..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreData


extension TIME_LOG {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TIME_LOG> {
        return NSFetchRequest<TIME_LOG>(entityName: "TIME_LOG");
    }

    @NSManaged public var regdt: NSDate?
    @NSManaged public var studytime: Double
    @NSManaged public var uid: String?
    @NSManaged public var type: String?
    @NSManaged public var vid: String?

}
