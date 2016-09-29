//
//  File.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

protocol hTableViewCell {
    associatedtype Item
    
    func update(data: Item) -> UITableViewCell
}
