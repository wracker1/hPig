//
//  NetService.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Alamofire

class NetService {
    static let shared: NetService = {
        let instance = NetService()
        return instance
    }()
    
    private let host = "http://speakingtube.cafe24.com"
    
    func get(url: String) -> DataRequest {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        return Alamofire.request("\(host)\(url)").response(completionHandler: { _ in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        })
    }
    
    func getObject<T: ResponseObjectSerializable>(path: String, completionHandler: @escaping (DataResponse<T>) -> Void) -> Void {
        get(url: path).responseObject(completionHandler: completionHandler)
    }
    
    func getCollection<T: ResponseCollectionSerializable>(path: String, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Void {
        get(url: path).responseCollection(completionHandler: completionHandler)
    }
}
