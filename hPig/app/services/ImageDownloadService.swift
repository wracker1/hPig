//
//  ImageDownloadService.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

class ImageDownloadService {
    static let shared: ImageDownloadService = {
        let instance = ImageDownloadService()
        return instance
    }()
    
    private let imageDownloader: ImageDownloader = {
        let configuration = URLSessionConfiguration.default
        
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.httpShouldSetCookies = true
        configuration.httpShouldUsePipelining = false
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.allowsCellularAccess = true
        configuration.timeoutIntervalForRequest = 30
        configuration.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024, // 50 MB
            diskCapacity: 150 * 1024 * 1024,  // 150 MB
            diskPath: "org.alamofire.imagedownloader"
        )
        
        
        return ImageDownloader(
            configuration: configuration,
            downloadPrioritization: .fifo,
            maximumActiveDownloads: 6,
            imageCache: AutoPurgingImageCache()
        )
    }()
    
    func get(url: String, filter: ImageFilter?, completionHandler: ((DataResponse<Image>) -> Void)?) {
        if let item = URL(string: url) {
            let req = URLRequest(url: item)
            
            print("GET IMAGE: \(url)")
            
            imageDownloader.download(
                req,
                receiptID: url,
                filter: filter,
                progress: nil,
                progressQueue: DispatchQueue.global(),
                completion: completionHandler
            )
        }
    }
    
    func decorateChannelButton(_ button: UIButton, imageUrl: String) {
        ImageDownloadService.shared.get(url: imageUrl, filter: nil, completionHandler: { (res) in
            button.setImage(res.result.value, for: .normal)
            button.imageView?.clipsToBounds = true
            button.imageView?.contentMode = .scaleAspectFill
            button.imageView?.layer.cornerRadius = 18.0
            button.imageView?.layer.borderColor = UIColor.white.cgColor
            button.imageView?.layer.borderWidth = 1.0
        })
    }
}
