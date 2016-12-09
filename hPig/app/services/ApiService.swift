//
//  ApiService.swift
//  hPig
//
//  Created by Jesse on 2016. 12. 9..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import Alamofire

class ApiService {
    static let shared: ApiService = {
        return ApiService()
    }()
    
    func basicStudySubtitleData(id: String, part: Int, duration: String?, completion: (([BasicStudy]) -> Void)?) {
        NetService.shared.getCollection(path: "/svc/api/v2/caption/\(id)/\(part)") { (res: DataResponse<[BasicStudy]>) in
            if let data = res.result.value {
                let basicData = data.enumerated().map({ (i, item) -> BasicStudy in
                    var sub = item
                    let next = data.get(i + 1)
                    sub.endTime = next == nil ? duration : next?.startTime
                    return sub
                })
                
                if let callback = completion {
                    callback(basicData)
                }
            } else {
                if let callback = completion {
                    callback([BasicStudy]())
                }
            }
        }
    }
    
    func patternStudySubtitleData(id: String, part: Int, completion: (([PatternStudy]) -> Void)?) {
        NetService.shared.getCollection(path: "/svc/api/v2/pattern/\(id)/\(part)") { (res: DataResponse<[PatternStudy]>) in
            if let callback = completion {
                callback(res.result.value ?? [PatternStudy]())
            }
        }
    }
    
    func updateRemotePushSetting(_ idOrEmail: String, isOn: Bool) {
        let param = [
            "id": idOrEmail,
            "pushyn": isOn ? "Y" : "N"
        ]
        
        NetService.shared.get(path: "/svc/api/user/update/pushyn", parameters: param).responseString(completionHandler: { (res) in
            if let message = res.result.value {
                print(message)
            }
        })
    }
    
    func registerCoupon(_ idOrEmail: String, coupon: String, completion: ((String) -> Void)?) {
        let params = ["id": idOrEmail, "coupon": coupon.uppercased()]
        
        NetService.shared.get(path: "/svc/api/user/update/coupon", parameters: params).responseString(completionHandler: { (res) in
            var message = "등록에 실패하였습니다. 다시 시도해주세요"
            
            if let result = res.result.value {
                switch result.lowercased() {
                case "success":
                    AuthenticateService.shared.updateTubeUserInfo(idOrEmail, completion: nil)
                    message = "등록 하였습니다"
                    
                case "duplicated":
                    message = "이미 등록된 쿠폰 번호입니다"
                    
                case "not_available":
                    message = "유효하지 않은 쿠폰 번호입니다"
                    
                default:
                    message = "등록에 실패하였습니다. 다시 시도해주세요"
                }
            }
            
            if let callback = completion {
                callback(message)
            }
        })
    }
    
    func timeLineSessions(sort: String, category: String, level: String, page: Int, completion: (([Session]) -> Void)?) {
        NetService.shared.getCollection(path: "/svc/api/list/\(sort)/\(category)/\(level)/\(page)", completionHandler: { (res: DataResponse<[Session]>) in
            
            if let callback = completion {
                let items = res.result.value?.filter({ (session) -> Bool in
                    return (session.status ?? "N") == "Y"
                }) ?? [Session]()
                
                callback(items)
            }
        })
    }
    
    func latestCategorySessions(category: String, excludeId: String?, completion: (([Session]) -> Void)?) {
        NetService.shared.getCollection(path: "/svc/api/list/new/\(category)/0/1") { (res: DataResponse<[Session]>) in
            if let callback = completion {
                let sessions = res.result.value?.filter({ (item) -> Bool in
                    let isAvailable = (item.status ?? "N") == "Y"
                    var isInclude = true
                    
                    if let exId = excludeId {
                        isInclude = item.id != exId
                    }
                    
                    return isAvailable && isInclude
                }) ?? [Session]()
                
                callback(sessions)
            }
        }
    }
    
    func categories(completion: (([Category]) -> Void)?) {
        NetService.shared.getCollection(path: "/svc/api/category", completionHandler: { (res: DataResponse<[Category]>) in
            if let callback = completion {
                callback(res.result.value ?? [Category]())
            }
        })
    }
    
    func channelData(channelId: String, completion: ((Channel?) -> Void)?) {
        NetService.shared.getObject(path: "/svc/api/channel/\(channelId)", completionHandler: { (res: DataResponse<Channel>) in
            if let callback = completion {
                callback(res.result.value)
            }
        })
    }
    
    func wordSoundData(word: WordData, completion: ((Data?) -> Void)?) {
        if let url = URL(string: word.soundUrl) {
            let req = URLRequest(url: url)
            
            NetService.shared.get(req: req).responseData(completionHandler: { (res) in
                if let callback = completion {
                    callback(res.result.value)
                }
            })
        }
    }
    
    func dictionaryData(word: String, completion: ((WordData?) -> Void)?) {
        NetService.shared.getObject(path: "/svc/api/dictionary/\(word)", completionHandler: { (res: DataResponse<WordData>) in
            if let callback = completion {
                callback(res.result.value)
            }
        })
    }
    
    func appStorePurchaseItems(completion: (([hPass]) -> Void)?) {
        DispatchQueue.global().async {
            NetService.shared.get(path: "/svc/api/purchase/ios/item").responseJSON { (res) in
                if let data = res.result.value as? [String: Any], let items = data["items"] as? [Any] {
                    let passes = items.flatMap({ (item) -> hPass? in
                        return hPass(item)
                    })
                    
                    if let callback = completion {
                        DispatchQueue.main.async {
                            callback(passes)
                        }
                    }
                } else {
                    if let callback = completion {
                        DispatchQueue.main.async {
                            callback([hPass]())
                        }
                    }
                }
            }
        }
    }
    
    func registerPass(_ idOrEmail: String, passType: String, completion: ((Error?) -> Void)?) {
        let params: [String : String] = ["id": idOrEmail, "passtype": passType]
        
        NetService.shared.post(path: "/svc/api/user/update/pass", parameters: params).responseString(completionHandler: { (res) in
            if let callback = completion {
                callback(res.result.error)
            }
        })
    }
    
    func updatePlayCount(vid: String, part: String) {
        NetService.shared.get(path: "/svc/api/video/update/playcnt?id=\(vid)&part=\(part)")
    }
    
    func updateStudyTime(_ idOrEmail: String, sec: Int) {
        NetService.shared.get(path: "/svc/api/user/update/studytime?id=\(idOrEmail)&time=\(sec)")
    }
    
    func updateVisitCount(_ idOrEmail: String, deviceToken: String?, completion: ((String) -> Void)?) {
        let param = [
            "id": idOrEmail,
            "token": deviceToken ?? ""
        ]
        
        NetService.shared.get(path: "/svc/api/user/update/visitcnt", parameters: param).responseString(completionHandler: { (res) in
            if let callback = completion {
                callback(res.result.value ?? "")
            }
        })
    }
    
    func naverUserInfo(accessToken: String, completion: ((Data?) -> Void)?) {
        NetService.shared.get("https://apis.naver.com/nidlogin/nid/getUserProfile.xml",
                              parameters: nil,
                              headers: ["Authorization": "Bearer \(accessToken)"]).response { (res) in
                                if let callback = completion {
                                    callback(res.data)
                                }
        }
    }
    
    func speakingTubeUserInfo(_ idOrEmail: String, completion: ((TubeUserInfo?) -> Void)?) {
        NetService.shared.getObject(path: "/svc/api/user/info?id=\(idOrEmail)", completionHandler: { (res: DataResponse<TubeUserInfo>) in
            if let callback = completion {
                callback(res.result.value)
            }
        })
    }
    
    func joinUser(user: User, deviceToken: String?, completion: ((Bool) -> Void)?) {
        var parameters: [String: Any] = ["id": user.id, "os": "I"]
        
        if let age = user.age {
            do {
                let regex = try NSRegularExpression(pattern: "[^-d]*", options: .caseInsensitive)
                let range = NSRange(location: 0, length: age.characters.count)
                
                if let match = regex.firstMatch(in: age, options: [], range: range) {
                    parameters["age"] = (age as NSString).substring(with: match.range)
                }
            } catch let e {
                print("\(e)")
            }
        }
        
        if let gender = user.gender {
            parameters["gender"] = gender
        }
        
        
        if let nickname = user.nickname {
            parameters["nickname"] = nickname
        }
        
        if let image = user.profileImage {
            parameters["image"] = image
        }
        
        if let token = deviceToken {
            parameters["token"] = token
        }
        
        NetService.shared.post(path: "/svc/api/user/join", parameters: parameters).responseString(completionHandler: { (res) in
            if let callback = completion {
                callback(res.result.value != nil)
            }
        })
    }
}
