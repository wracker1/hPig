//
//  ViewController.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import Alamofire

class SessionsController: UITableViewController {

    private var currentPage = 0
    private var hasNext = true
    private var isLoading = false
    private var sessions: [Session] = []
    private var sort = "new"
    private var category = "0"
    private var level = "0"
    private var tableViewVelocity: CGPoint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPage(sort: sort, category: category, level: level, page: 1) {
            
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    private func loadPage(sort: String, category: String, level: String, page: Int, completion: @escaping () -> Void) -> Void {
        if page == 1 {
            self.hasNext = true
        }
        
        if hasNext && !isLoading {
            
            self.isLoading = true
    
            NetService.shared.getCollection(path: "/svc/api/list/\(sort)/\(category)/\(level)/\(page)", completionHandler: { (res: DataResponse<[Session]>) in
                if let items = res.result.value?.filter({ (session) -> Bool in
                    return session.status == "Y"
                }) {
                    self.hasNext = items.count > 9
                    
//                    let current = self.sessions.count
                    
                    if page == 1 {
                        self.sessions = items
                        self.tableView.reloadData()
                    } else {
                        self.sessions += items
//                        self.insertRows(current, size: items.count)
                    }
                }
                
                completion()
                
                self.sort = sort
                self.category = category
                self.level = level
                self.currentPage = page
                self.isLoading = false
            })
            
//            NetClient.shared.getArray("/svc/api/list/\(sort)/\(category)/\(level)/\(page)") { (res: Response<[Session], NSError>) in
//                if let items = res.result.value?.filter({ (session) -> Bool in
//                    return (session.status ?? "N") == "Y"
//                }) {
//                    self.hasNext = items.count > 9
//                    
//                    let current = self.sessions.count
//                    
//                    if page == 1 {
//                        self.sessions = items
//                        self.tableView.reloadData()
//                    } else {
//                        self.sessions += items
//                        self.insertRows(current, size: items.count)
//                    }
//                }
//                
//                completion()
//                
//                self.sort = sort
//                self.category = category
//                self.level = level
//                self.currentPage = page
//                self.isLoading = false
//            }
        } else {
            completion()
        }
    }
}

