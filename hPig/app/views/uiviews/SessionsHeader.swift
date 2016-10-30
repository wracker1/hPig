//
//  SessionsHeader.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 31..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class SessionsHeader: UITableViewHeaderFooterView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        LayoutService.shared.layoutXibViews(superview: self, nibName: "sessions_header", viewLayoutBlock: nil)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        LayoutService.shared.layoutXibViews(superview: self, nibName: "sessions_header", viewLayoutBlock: nil)
    }

}
