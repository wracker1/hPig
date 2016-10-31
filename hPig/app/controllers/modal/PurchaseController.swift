//
//  hPig
//
//  Created by Jesse on 2016. 10. 28..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import StoreKit
import CoreGraphics

class PurchaseController: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var twelveButton: UIButton!
    
    @IBOutlet weak var oneWrap: UIView!
    @IBOutlet weak var threeWrap: UIView!
    @IBOutlet weak var sixWrap: UIView!
    @IBOutlet weak var twelveWrap: UIView!
    
    private let paymentQueue = SKPaymentQueue.default()
    
    var controller: UIViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        [oneButton, threeButton, sixButton, twelveButton].forEach { (button) in
            button!.layer.borderColor = UIColor.red.cgColor
            button!.layer.borderWidth = 1.0
        }
        
        [oneWrap, threeWrap, sixWrap, twelveWrap].forEach { (wrap) in
            wrap!.layer.borderColor = UIColor.lightGray.cgColor
            wrap!.layer.borderWidth = 1.0
        }
        
        paymentQueue.add(self)
    }
    
    deinit {
        paymentQueue.remove(self)
    }
    
    @IBAction func purchase(_ sender: AnyObject) {
        if let button = sender as? UIButton, let id = button.restorationIdentifier {
            if SKPaymentQueue.canMakePayments() {
                let purchaseId = Set(arrayLiteral: id)
                let req = SKProductsRequest(productIdentifiers: purchaseId)
                req.delegate = self
                req.start()
            } else {
                self.view.presentToast("구매를 활성화 할 수 없습니다.")
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        
        if let product = products.get(0) {
            let payment = SKPayment(product: product)
            paymentQueue.add(payment)
        } else {
            self.view.presentToast("상품을 찾을 수 없습니다.")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                updatePurchaseInfo(transaction.payment.productIdentifier)
                finishTransaction(transaction)
                
            case .failed:
                finishTransaction(transaction)
                
            default:
                break
            }
        }
    }
    
    private func updatePurchaseInfo(_ id: String) {
//        http://speakingtube.cafe24.com/svc/api/user/update/pass?id="+userId+"&passtype="+passtype+"&info=" + info
        AuthenticateService.shared.user { (user) in
            if let tubeUser = user {
//                tubeUser.id
//                NetService.shared.get(path: "/svc/api/user/update/pass", para)
            }
        }
    }
    
    private func finishTransaction(_ transaction: SKPaymentTransaction) {
        paymentQueue.finishTransaction(transaction)
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        if let vc = controller {
            vc.dismiss(animated: true, completion: nil)
        }
    }
}
