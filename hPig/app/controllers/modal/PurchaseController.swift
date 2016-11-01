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
    
    private let purchaseService = PurchaseService.shared
    private var passes = [String : hPass]()
    private var payments = [SKPayment]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        purchaseService.requestPassItems { (passItems) in
            passItems.forEach({ (pass) in
                self.passes[pass.id] = pass
            })
            
            self.purchaseService.requestPayments(ids: self.purchaseService.passesToIds(passes: passItems), completion: { (payments) in
                self.payments = payments
                
                self.tableView.reloadData()
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let payment = payments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath)
        
        if let item = passes[payment.productIdentifier], let paymentCell = cell as? PaymentCell {
            paymentCell.payment = payment
            paymentCell.passTitle.text = "\(item.name) (\(item.value))"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let payment = payments[indexPath.row]
        
        purchaseService.purchase(payment: payment) { (error) in
            if let reason = error {
                print(reason.localizedDescription)
            }
        }
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        if let vc = controller {
            vc.dismiss(animated: true, completion: nil)
        }
    }
}
