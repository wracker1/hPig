//
//  hWebViewController.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 13..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import WebKit

class hWebViewController: UIViewController {
    
    var url: String = ""

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let req = URLRequest(url: URL(string: url)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10000)
        
        webView.load(req)
        
        if let temp = (webView.subviews.find { (view) -> Bool in
            return (view as? UIScrollView) != nil
        }), let scrollView = temp as? UIScrollView {
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
