//
//  WORD+CoreDataProperties.swift
//  hPig
//
//  Created by 이동현 on 2016. 11. 1..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import CoreData


extension WORD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WORD> {
        return NSFetchRequest<WORD>(entityName: "WORD");
    }

    @NSManaged public var count: Int64
    @NSManaged public var id: String?
    @NSManaged public var pron: String?
    @NSManaged public var pronfile: String?
    @NSManaged public var regdt: NSDate?
    @NSManaged public var sentence: String?
    @NSManaged public var summary: String?
    @NSManaged public var uid: String?
    @NSManaged public var word: String?
    @NSManaged public var korean: String?
    @NSManaged public var vid: String?
    @NSManaged public var part: String?
    @NSManaged public var svctype: String?
    @NSManaged public var image: String?
    @NSManaged public var channelId: String?
    @NSManaged public var channelImage: String?
    @NSManaged public var channelName: String?
    @NSManaged public var title: String?
    @NSManaged public var duration: String?
    @NSManaged public var time: Float

}
