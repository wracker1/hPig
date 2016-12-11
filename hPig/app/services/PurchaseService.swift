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
    
    private let paymentQueue = SKPaymentQueue.default()
    private var passes = [hPass]()
    private var payments = [SKPayment]()
    
    private let keyUnprocessedTransaction = "unprocessedTransaction"
    private var paymentCompletion: (([SKPayment]) -> Void)? = nil
    private var purchaseCompletion: ((String?, Error?) -> Void)? = nil
    
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
                self.passes = passes
                
                if let callback = completion {
                    callback(passes)
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
    
    func purchase(_ viewController: UIViewController, payment: SKPayment, completion: ((String?, Error?) -> Void)?) {
        LoginService.shared.user({ (data) in
            if data == nil {
                AuthenticateService.shared.confirmLogin(viewController, completion: nil)
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
        LoginService.shared.user({ (data) in
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased:
                    self.updatePassInfo(data?.id, transaction: transaction)
                    
                case .failed:
                    queue.finishTransaction(transaction)

                    if let callback = self.purchaseCompletion {
                        DispatchQueue.main.async {
                            callback(data?.id, transaction.error)
                        }
                    }
                default:
                    break
                }
            }
        })
    }
    
    private func updatePassInfo(_ userId: String?, transaction: SKPaymentTransaction) {
        var passMap: [String : hPass] = [:]

        passes.forEach { (pass) in
            passMap[pass.id] = pass
        }
        
        if let id = userId, let pass = passMap[transaction.payment.productIdentifier] {
            let params: [String : String] = ["id": id, "passtype": pass.tubePassType()]
            UserDefaults.standard.set(params, forKey: self.keyUnprocessedTransaction)
            UserDefaults.standard.synchronize()
            
            self.requestUpdatePassType(idOrEmail: id, passType: pass.tubePassType(), completion: { (error) in
                if error == nil {
                    self.paymentQueue.finishTransaction(transaction)
                } else {
                    self.paymentQueue.restoreCompletedTransactions()
                }
                
                if let callback = self.purchaseCompletion {
                    DispatchQueue.main.async {
                        callback(id, error)
                    }
                }
            })
        }
    }
    
    private func requestUpdatePassType(idOrEmail: String, passType: String, completion: ((Error?) -> Void)?) {
        ApiService.shared.registerPass(idOrEmail, passType: passType, completion: { (res) in
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
            let passType = params["passtype"] {
            
            requestUpdatePassType(idOrEmail: id, passType: passType, completion: nil)
        }
        
        return self
    }
}
