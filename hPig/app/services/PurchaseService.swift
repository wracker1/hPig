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
    
    private var paymentCompletion: (([SKPayment]) -> Void)? = nil
    private var purchaseCompletion: ((Error?) -> Void)? = nil
    
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
            DispatchQueue.global().async {
                NetService.shared.get(path: "/svc/api/purchase/ios/item").responseJSON { (res) in
                    if let data = res.result.value as? [String: Any], let items = data["items"] as? [Any] {
                        let passes = items.flatMap({ (item) -> hPass? in
                            return hPass(item)
                        })
                        
                        if let callback = completion {
                            self.passes = passes
                            
                            DispatchQueue.main.async {
                                callback(passes)
                            }
                        }
                    }
                }
            }
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
    
    func update() {
        requestPassItems { (passes) in
            self.requestPayments(ids: self.passesToIds(passes: passes), completion: nil)
        }
    }
    
    func passesToIds(passes: [hPass]) -> [String] {
        return passes.map({ (item) -> String in
            return item.id
        })
    }
    
    func purchase(payment: SKPayment, completion: ((Error?) -> Void)?) {
        DispatchQueue.global().async {
            self.purchaseCompletion = completion
            self.paymentQueue.add(payment)
        }
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
        let callback = purchaseCompletion ?? {(_) in }
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                queue.finishTransaction(transaction)
                
                DispatchQueue.main.async {
                    callback(transaction.error)
                }
                
            case .failed:
                queue.finishTransaction(transaction)
                
                DispatchQueue.main.async {
                    callback(transaction.error)
                }
                
            default:
                break
            }
        }
    }
}
