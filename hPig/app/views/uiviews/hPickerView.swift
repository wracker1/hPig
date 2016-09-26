//
//  hPickerView.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class hPickerView: UIView {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        XibService.shared.layoutXibViews(superview: self, nibName: "picker_action_view") { (view) in
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        XibService.shared.layoutXibViews(superview:self, nibName: "picker_action_view") { (view) in
            
        }
    }
}