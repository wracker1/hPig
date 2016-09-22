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
    
    private let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 5,
        imageCache: AutoPurgingImageCache()
    )
    
    func get(url: String, filter: ImageFilter?, completionHandler: @escaping (DataResponse<Image>) -> Void) -> Void {
        let req = URLRequest(url: URL(string: url)!)
        
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
