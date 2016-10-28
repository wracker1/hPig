//
//  BuyPassController.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 28..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import StoreKit

class BuyPassController: UITableViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    private let ids = ["1month", "3month", "6month", "12month"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !AuthenticateService.shared.isOn() {
            AlertService.shared.presentConfirm(
                self,
                title: "로그인이 필요합니다. 로그인 하시겠습니까?",
                message: nil,
                cancel: nil,
                confirm: {
                    AuthenticateService.shared.tryLogin(self, completion: { (success) in
                        
                    })
            })
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ids.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = ids[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = ids[indexPath.row]
        
        buy(id)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "패스 구매"
    }
    
    private func buy(_ id: String) {
        SKPaymentQueue.default().add(self)
        
        if SKPaymentQueue.canMakePayments() {
            let req = SKProductsRequest(productIdentifiers: Set(arrayLiteral: id))
            req.delegate = self
            req.start()
        } else {
            self.view.presentToast("구매를 활성화 할 수 없습니다.")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        
        if products.count > 0 {
            let product = products[0]
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            self.view.presentToast("상품을 찾을 수 없습니다.")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                finishTransaction(transaction)
                
            case .failed:
                finishTransaction(transaction)
                
            default:
                break
            }
        }
    }
    
    private func finishTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
