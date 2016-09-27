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
        configuration.requestCachePolicy = .useProtocolCachePolicy
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
    
    func get(url: String, filter: ImageFilter?, completionHandler: @escaping (DataResponse<Image>) -> Void) {
        let req = URLRequest(url: URL(string: url)!)
        
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
