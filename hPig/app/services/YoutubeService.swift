//
//  YoutubeService.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

class YoutubeService {
    static let shared: YoutubeService = {
        let instance = YoutubeService()
        return instance
    }()
    
    private let regex = "value=\"(\\D.{1,8})\"><\\/td><td><input[^>]*?value=\"video\\/mp4[^>]*?>[\\s\\S]*?href=\"([^\"]*)\""
    
    private func defaultRequestWithUrl() -> URLRequest {
        let url = URL(string: "https://www.h3xed.com/blogmedia/youtube-info.php")!
        var req = URLRequest(url: url)
        
        req.httpMethod = "POST"
        req.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/601.7.8 (KHTML, like Gecko) Version/9.1.3 Safari/601.7.8", forHTTPHeaderField: "User-Agent")
        req.addValue("https://www.h3xed.com", forHTTPHeaderField: "Origin")
        
        return req
    }
    
    func videoInfo(id: String, completion: @escaping ([YoutubeVideo], Error?) -> Void) -> Void {
        DispatchQueue.global().async {
            var req = self.defaultRequestWithUrl()
            req.httpBody = "ytdurl=\(id)".data(using: String.Encoding.utf8)
            
            let task = URLSession.shared.dataTask(with: req) { (data, res, error) in
                
                if let item = data {
                    do {
                        let html = String(data: item, encoding: .utf8)!
                        let tableReg = try NSRegularExpression(pattern: self.regex, options: .caseInsensitive)
                        let matches = tableReg.matches(in: html, options: .reportProgress, range: NSMakeRange(0, html.characters.count))
                        
                        let videoInfo = matches.map({ (result) -> YoutubeVideo in
                            let quality = (html as NSString).substring(with: result.rangeAt(1))
                            let url = (html as NSString).substring(with: result.rangeAt(2))
                            return YoutubeVideo(quality: quality, url: url)
                        })
                        
                        DispatchQueue.main.async {
                            completion(videoInfo, nil)
                        }
                    } catch let e {
                        DispatchQueue.main.async {
                            completion([], e)
                        }
                    }
                }
            }
            
            task.resume()
        }
    }
}
