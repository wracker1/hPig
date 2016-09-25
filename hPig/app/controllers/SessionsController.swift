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
    
    @IBOutlet weak var listFilterButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "speaking_tube"))
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 400
        self.refreshControl?.addTarget(self, action: #selector(self.reloadSessions), for: .valueChanged)
        
        self.listFilterButton.target = self
        self.listFilterButton.action = #selector(self.showListFilterPicker)
        
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let session = sessions[indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellId(session: session), for: indexPath)
        
        if session.type.lowercased() == "banner" {
            return (cell as! BannerCell).update(data: session)
        } else {
            return (cell as! SessionCell).update(data: session)
        }
    }

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
                    
                    let current = self.sessions.count
                    
                    if page == 1 {
                        self.sessions = items
                        self.tableView.reloadData()
                    } else {
                        self.sessions += items
                        self.insertRows(from: current, size: items.count)
                    }
                }
                
                completion()
                
                self.sort = sort
                self.category = category
                self.level = level
                self.currentPage = page
                self.isLoading = false
            })
        } else {
            completion()
        }
    }
    
    private func insertRows(from: Int, size: Int) {
        let offset = self.tableView.contentOffset
        let to = from + size
        let indexPaths = (from..<to).map { (i) -> IndexPath in
            return IndexPath(row: i, section: 0)
        }
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: indexPaths, with: .fade)
        self.tableView.setContentOffset(offset, animated: false)
        self.tableView.endUpdates()
    }
    
    func reloadSessions(control: UIRefreshControl) {
        loadPage(sort: sort, category: category, level: level, page: 1) {
            self.refreshControl?.endRefreshing()
        }
    }
    
    func showListFilterPicker() {
        CategoryService.shared.presentSessionListFilter(viewController: self, sort: sort, category: category, level: level) { (sort, category, level) in
            let isChanged = self.sort != sort || self.category != category || self.level != level
            
            if isChanged {
                self.loadPage(sort: sort ?? "new", category: category ?? "0", level: level ?? "0", page: 1, completion: {})
            }
        }
    }
    
    private func cellId(session: Session) -> String {
        if session.type.lowercased() == "banner" {
            return "BannerCell"
        } else {
            return "SessionCell"
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (self.sessions.count - 2) < indexPath.row {
            loadPage(sort: sort, category: category, level: level, page: currentPage + 1) {
                
            }
        }
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (decelerate) {
            tableViewVelocity.fold({ () -> Void in
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                }, f: { (velocity) -> Void in
                    if velocity.y > 0 {
                        self.navigationController?.setNavigationBarHidden(true, animated: true)
                    } else {
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                    }
            })
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.tableViewVelocity = velocity
    }
    
    override func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = self.tableView.indexPathForSelectedRow?.row
        let session = self.sessions[index!]
        let type = session.type
        
        if type.lowercased() == "banner" {
            
        } else {
            let vc = segue.destination as! SessionController
            vc.session = session
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

