//
//  PurchaseService.swift
//  hPig
//
//  Created by Jesse on 2016. 11. 1..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation
import StoreKit

class PurchaseService: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    static let shared: PurchaseService = {
        return PurchaseService()
    }()
    
    private let passConvertMap = ["1month": "oneMonth",
                                  "3month": "threeMonth",
                                  "6month": "sixMonth",
                                  "12month": "yearPass"]
    
    private let paymentQueue = SKPaymentQueue.default()
    private var passes = [hPass]()
    private var payments = [SKPayment]()
    private weak var viewController: UIViewController? = nil
    
    private let keyUnprocessedTransaction = "unprocessedTransaction"
    private var paymentCompletion: (([SKPayment]) -> Void)? = nil
    private var purchaseCompletion: ((User?, Error?) -> Void)? = nil
    
    override init() {
        super.init()
        
        paymentQueue.add(self)
    }
    
    deinit {
        paymentQueue.remove(self)
    }
    
    func requestPassItems(_ completion: (([hPass]) -> Void)?) {
        if passes.count > 0 {
            if let callback = completion {
                callback(passes)
            }
        } else {
            ApiService.shared.appStorePurchaseItems(completion: { (passes) in
                let items = passes.map({ (pass) -> hPass in
                    if let id = self.passConvertMap[pass.id] {
                        return hPass(id: id, name: pass.name, value: pass.value, passType: pass.passType)
                    } else {
                        return pass
                    }
                })
                
                self.passes = items
                
                if let callback = completion {
                    callback(items)
                }
            })
        }
    }

    func requestPayments(ids: [String], completion: (([SKPayment]) -> Void)?) {
        if payments.count > 0 {
            if let callback = completion {
                callback(payments)
            }
        } else {
            DispatchQueue.global().async {
                if SKPaymentQueue.canMakePayments() {
                    self.paymentCompletion = completion
                    
                    let req = SKProductsRequest(productIdentifiers: Set(ids))
                    req.delegate = self
                    req.start()
                } else if let callback = completion {
                    
                    self.viewController?.view.presentToast("구매를 할 수 없는 상태입니다")
                    
                    DispatchQueue.main.async {
                        callback(self.payments)
                    }
                }
            }
        }
    }
    
    func passesToIds(passes: [hPass]) -> [String] {
        return passes.map({ (item) -> String in
            return item.id
        })
    }
    
    func purchase(_ viewController: UIViewController, sourceView: UIView?, payment: SKPayment, completion: ((User?, Error?) -> Void)?) {
        self.viewController = viewController
        
        LoginService.shared.user({ (tuser, user) in
            if tuser == nil {
                AuthenticateService.shared.confirmLogin(viewController, sourceView: sourceView, completion: nil)
            } else {
                DispatchQueue.global().async {
                    self.purchaseCompletion = completion
                    self.paymentQueue.add(payment)
                }
            }
        })
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.payments = response.products.map({ (product) -> SKPayment in
            return SKPayment(product: product)
        }).sorted(by: { (pay1, pay2) -> Bool in
            return pay1.productIdentifier > pay2.productIdentifier
        })

        if let callback = paymentCompletion {
            callback(self.payments)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        LoginService.shared.user({ (tuser, user) in
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased:
                    if let uData = user {
                        self.updatePassInfo(uData, transaction: transaction)
                    }
                    
                case .restored:
                    if let uData = user {
                        self.saveTransaction(uData, transaction: transaction)
                    }
                    
                case .failed:
                    queue.finishTransaction(transaction)

                    if let callback = self.purchaseCompletion {
                        DispatchQueue.main.async {
                            callback(user, transaction.error)
                        }
                    }
                default:
                    break
                }
            }
        })
    }
    
    @discardableResult private func saveTransaction(_ user: User, transaction: SKPaymentTransaction) -> hPass? {
        var passMap: [String : hPass] = [:]
        
        passes.forEach { (pass) in
            passMap[pass.id] = pass
        }
        
        if let pass = passMap[transaction.payment.productIdentifier] {
            let params: [String : String] = ["id": user.id,
                                             "passtype": pass.tubePassType(),
                                             "loginType": user.loginType.rawValue]
            
            UserDefaults.standard.set(params, forKey: self.keyUnprocessedTransaction)
            UserDefaults.standard.synchronize()
            
            return pass
        } else {
            return nil
        }
    }
    
    private func updatePassInfo(_ user: User, transaction: SKPaymentTransaction) {
        if let pass = saveTransaction(user, transaction: transaction) {
            self.requestUpdatePassType(user.id, loginType: user.loginType, passType: pass.tubePassType(), completion: { (error) in
                if error == nil {
                    self.paymentQueue.finishTransaction(transaction)
                } else {
                    self.paymentQueue.restoreCompletedTransactions()
                }
                
                if let callback = self.purchaseCompletion {
                    DispatchQueue.main.async {
                        callback(user, error)
                    }
                }
            })
        } else {
            viewController?.view.presentToast("구매정보를 찾을 수 없습니다.")
        }
    }
    
    private func requestUpdatePassType(_ id: String, loginType: LoginType, passType: String, completion: ((Error?) -> Void)?) {
        ApiService.shared.registerPass(id, loginType: loginType, passType: passType, completion: { (res) in
            if res == nil {
                UserDefaults.standard.removeObject(forKey: self.keyUnprocessedTransaction)
                UserDefaults.standard.synchronize()
            }
            
            if let callback = completion {
                callback(res)
            }
        })
    }
    
    @discardableResult func update() -> PurchaseService {
        requestPassItems { (passes) in
            self.requestPayments(ids: self.passesToIds(passes: passes), completion: nil)
        }
        
        return self
    }
    
    @discardableResult func processPastPurchase() -> PurchaseService {
        if let params = UserDefaults.standard.value(forKey: keyUnprocessedTransaction) as? [String : String],
            let id = params["id"],
            let passType = params["passtype"],
            let raw = params["loginType"],
            let loginType = LoginType(rawValue: raw) {
            
            requestUpdatePassType(id, loginType: loginType, passType: passType, completion: nil)
        }
        
        return self
    }
}
