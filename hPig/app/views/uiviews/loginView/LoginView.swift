//
//  LoginView.swift
//  hPig
//
//  Created by Jesse on 2016. 12. 13..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import CoreGraphics

class LoginView: UIView {

    @IBOutlet weak var kakaoButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var naverButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
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
        
        closeButton.layer.borderColor = secondPointColor.cgColor
        closeButton.layer.borderWidth = 1.0
    }    
}
