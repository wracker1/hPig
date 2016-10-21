//
//  WORD+CoreDataProperties.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreData


extension WORD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WORD> {
        return NSFetchRequest<WORD>(entityName: "WORD");
    }

    @NSManaged public var id: String?
    @NSManaged public var pron: String?
    @NSManaged public var pronfile: String?
    @NSManaged public var regdt: NSDate?
    @NSManaged public var summary: String?
    @NSManaged public var uid: String?
    @NSManaged public var word: String?
    @NSManaged public var count: Int64

}
