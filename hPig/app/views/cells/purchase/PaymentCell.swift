//
//  PaymentCell.swift
//  hPig
//
//  Created by 이동현 on 2016. 11. 2..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import StoreKit

class PaymentCell: UITableViewCell {
    
    var payment: SKPayment? = nil
    
    @IBOutlet weak var passTitle: UILabel!
}
