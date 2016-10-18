//
//  NetService.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import Alamofire

class NetService {
    static let shared: NetService = {
        let instance = NetService()
        return instance
    }()
    
    private let host = "http://speakingtube.cafe24.com"
    
    func get(req: URLRequest) -> DataRequest {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if let url = req.url {
            print("GET =======================> url: \(url)")
        }
        
        return Alamofire.request(req).response(completionHandler: { _ in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        })
    }
    
    func get(path: String) -> DataRequest {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = "\(host)\(path)"
        
        print("GET =======================> url: \(url)")
        
        return Alamofire.request(url).response(completionHandler: { _ in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        })
    }
    
    func post(path: String, parameters: Parameters?) -> DataRequest {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = "\(host)\(path)"
        
        print("POST =======================> url: \(url), parameter: \(parameters)")
        
        return Alamofire.request(url, method: .post, parameters: parameters).response(completionHandler: { _ in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        })
    }
    
    @discardableResult func getObject<T: ResponseObjectSerializable>(path: String, completionHandler: @escaping (DataResponse<T>) -> Void) -> DataRequest {
        return get(path: path).responseObject(completionHandler: completionHandler)
    }
    
    @discardableResult func getCollection<T: ResponseCollectionSerializable>(path: String, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Void {
        get(path: path).responseCollection(completionHandler: completionHandler)
    }
}
