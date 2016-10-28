//
//  UIScrollViewOps.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 27..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit

let preLoadPage = 2

extension UIScrollView {
    
    func shouldLoadNext(_ scrollVelocity: CGPoint?, hasNext: Bool, isLoading: Bool) -> Bool {
        let size = self.bounds.size
        let needToLoad = hasNext && !isLoading && (self.contentOffset.y + size.height * CGFloat(preLoadPage)) > self.contentSize.height
        
        if let velocity = scrollVelocity, velocity.y > 0.0 && needToLoad {
            return true
        } else {
            return needToLoad
        }
    }
}
