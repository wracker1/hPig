//
//  AlertService.swift
//  hPig
//
//  Created by 이동현 on 2016. 10. 13..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

class AlertService {
    static let shared: AlertService = {
        let instance = AlertService()
        return instance
    }()
    
    func present(_ viewController: UIViewController, title: String?, message: String?, completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: completion)
    }
}
