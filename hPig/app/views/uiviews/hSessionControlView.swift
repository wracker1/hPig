//
//  hSessionControlView.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class hSessionControlView: UIView {

    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        LayoutService.shared.layoutXibViews(superview: self, nibName: "session_nav_view", viewLayoutBlock: nil)
    }

}
