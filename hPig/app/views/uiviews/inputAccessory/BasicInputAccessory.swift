//
//  BasicInputAccessory.swift
//  hPig
//
//  Created by 이동현 on 2016. 12. 16..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class BasicInputAccessory: UIView {
    @IBOutlet weak var closeButton: UIButton!
    
    required override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 50))
        
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadNib()
    }
    
    private func loadNib() {
        LayoutService.shared.layoutXibView(superview: self, nibName: "basic_accessory_view")
    }
}
