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
    private var passes = [hPass]()
    private var payments = [String: SKPayment]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "패스 구매"
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
            paymentCell.passTitle.text = "\(item.name) (\(item.value))"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pass = passes[indexPath.row]
        if let payment = payments[pass.id] {
            purchaseService.purchase(payment: payment) { (error) in
                if let reason = error {
                    self.view.presentToast(reason.localizedDescription)
                }
                
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "스피킹튜브 이용권"
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        if let vc = controller {
            vc.dismiss(animated: true, completion: nil)
        }
    }
}
