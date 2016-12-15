//
//  AuthenticateService.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 29..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

class AuthenticateService {
    static let shared: AuthenticateService = {
        let instance = AuthenticateService()
        return instance
    }()
    
    private var pushToken: String? = nil
    
    func joinUser(user: User, name: String?, completion: ((Bool) -> Void)?) {
        if user.id.isEmpty {
            if let callback = completion {
                callback(false)
            }
        } else {
            ApiService.shared.joinUser(user, name: name, deviceToken: deviceToken(), completion: completion)
        }
    }
    
    func deviceToken() -> String? {
        return UserDefaults.standard.value(forKey: kTokenKey) as? String ?? pushToken
    }
    
    func registerAPNSToken(_ token: String) {
        self.pushToken = token
        
        UserDefaults.standard.set(token, forKey: kTokenKey)
        UserDefaults.standard.synchronize()
    }
    
    func updateVisitCount(_ completion: ((TubeUserInfo?) -> Void)?) {
        let callback = completion ?? {(_) in }
        
        DispatchQueue.global().async {
            LoginService.shared.user({ (t, u) in
                if let user = u {
                    ApiService.shared.updateVisitCount(user.id, loginType: user.loginType, deviceToken: self.deviceToken(), completion: { (message) in
                        print("update visitcnt message: \(message)")
                        
                        callback(t)
                    })
                } else {
                    callback(t)
                }
            })
        }
    }
    
    func prepare(_ viewController: UIViewController, for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showPurchase":
                if let nav = segue.destination as? UINavigationController,
                    let top = nav.topViewController as? PurchaseController {
                    
                    top.controller = viewController
                }
            default:
                print("others")
            }
        }
    }
    
    @discardableResult func shouldPerform(_ id: String, viewController: UIViewController, sender: Any?, session: Session?) -> Bool {
        switch id {
        case "basicStudyFromMyInfo"
        , "basicStudyFromSessionMain"
        , "patternStudyFromSessionMain"
        , "patternStudyFromWorkBook":
            if let item = session {
                if item.isFree {
                    return true
                } else {
                    do {
                        return try LoginService.shared.isActiveUser()
                    } catch AuthError.needToLogin {
                        return self.handleNotLoginUser(id,
                                                       viewController: viewController,
                                                       sourceView: sender as? UIView,
                                                       sender: sender,
                                                       session: session)
                        
                    } catch AuthError.unauthorized {
                        return self.handleUnauthrizedUser(viewController)
                    } catch let e {
                        viewController.view.presentToast(e.localizedDescription)
                        return false
                    }
                }
            } else {
                return false
            }
        case "showPurchase":
            if LoginService.shared.isOn() {
                return true
            } else {
                return self.handleNotLoginUser(id,
                                               viewController: viewController,
                                               sourceView: sender as? UIView,
                                               sender: sender,
                                               session: session)
            }
            
        default:
            return true
        }
    }
    
    func confirmLogin(_ viewController: UIViewController, sourceView: UIView?, completion: ((TubeUserInfo?) -> Void)?) {
//        let alert = AlertService.shared.confirm(viewController,
//                                    title: "로그인이 필요합니다. 로그인 하시겠습니까?",
//                                    message: nil,
//                                    cancel: nil,
//                                    confirm: {
//                                        LoginService.shared.tryLogin(viewController,
//                                                                     sourceView: sourceView,
//                                                                     completion: completion)
//        })
//        
//        viewController.present(alert, animated: true, completion: nil)
        
        LoginService.shared.tryLogin(viewController,
                                     sourceView: sourceView,
                                     completion: completion)
    }
    
    private func handleNotLoginUser(_ id: String, viewController: UIViewController, sourceView: UIView?, sender: Any?, session: Session?) -> Bool {
        confirmLogin(viewController, sourceView: sourceView, completion: { (data) in
            if data != nil {
                viewController.performSegue(withIdentifier: id, sender: sender)
            }
        })
        
        return false
    }
    
    private func handleUnauthrizedUser(_ viewController: UIViewController) -> Bool {
        let keyUnauthActionCount = "kUnauthActionCount"
        var count = UserDefaults.standard.value(forKey: keyUnauthActionCount) as? Int ?? 0
        
        if count > 3 {
            let alert = AlertService.shared.confirm(viewController,
                                                    title: "이용권이 필요한 영상입니다. 이용권을 구매해보세요.",
                                                    message: nil,
                                                    cancel: nil,
                                                    confirm: { 
                let purchaseController = UIStoryboard(name: "Purchase", bundle: Bundle.main).instantiateViewController(withIdentifier: "purchaseNavController")
                viewController.present(purchaseController, animated: true, completion: nil)
            })
            
            viewController.present(alert, animated: true, completion: nil)
            
            count = 0
        } else {
            viewController.view.presentToast("이용권을 구매해주세요.")
            count += 1
            
        }
        
        UserDefaults.standard.set(count, forKey: keyUnauthActionCount)
        UserDefaults.standard.synchronize()
        
        return false
    }
    

}
