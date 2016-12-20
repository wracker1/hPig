//
//  hPig
//
//  Created by Jesse on 2016. 10. 28..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import StoreKit
import CoreGraphics

class PurchaseController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var controller: UIViewController? = nil
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var passDueLabel: UILabel!
    @IBOutlet weak var faqButton: UIButton!
    
    private let purchaseService = PurchaseService.shared
    private var passes = [hPass]()
    private var payments = [String: SKPayment]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "패스 구매"
        
        LoginService.shared.user { (t, u) in
            if let info = t, let enddt = info.enddt {
                self.passDueLabel.text = "토탈패스 \(enddt) 까지"
            }
        }
        
        faqButton.cornerRadiusly()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        purchaseService.requestPassItems { (passItems) in
            self.purchaseService.requestPayments(ids: self.purchaseService.passesToIds(passes: passItems), completion: { (payments) in
                payments.forEach({ (payment) in
                    self.payments[payment.productIdentifier] = payment
                })
                
                self.passes = passItems.filter({ (pass) -> Bool in
                    return self.payments[pass.id] != nil
                })

                self.tableView.reloadData()
                
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { (_) in
                    self.tableViewHeight.constant = self.tableView.contentSize.height
                })
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = passes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath)
        
        if let paymentCell = cell as? PaymentCell {
            paymentCell.passTitle.text = item.name
            paymentCell.priceLabel.text = item.value
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pass = passes[indexPath.row]
        if let payment = payments[pass.id] {
            let cell = tableView.cellForRow(at: indexPath)
            
            purchaseService.purchase(self, sourceView: cell, payment: payment, completion: { (u, error) in
                if let reason = error {
                    self.view.presentToast(reason.localizedDescription)
                } else if let user = u {
                    LoginService.shared.tubeUserInfoFromServer(user.id, loginType: user.loginType, completion: { (_) in
                        self.view.presentToast("패스 구매가 완료되었습니다.", completion: {
                            self.dismiss(animated: true, completion: nil)
                        })
                    })
                }
                
                tableView.deselectRow(at: indexPath, animated: true)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPurchaseFaq", let webController = segue.destination as? hWebViewController {
            webController.url = "http://speakingtube.cafe24.com/faq_ios.html"
            webController.title = "패스구매에 대한 FAQ"
        }
    }
}
