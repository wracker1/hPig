//
//  LoginView.swift
//  hPig
//
//  Created by Jesse on 2016. 12. 13..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

class LoginView: UIView {

    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadNib()
    }
    
    private func loadNib() {
        LayoutService.shared.layoutXibView(superview: self, nibName: "login_view")
    }
}
