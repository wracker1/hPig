//
//  ViewController.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import Alamofire
import CoreGraphics

class SessionsController: UITableViewController {

    private var currentPage = 0
    private var hasNext = true
    private var isLoading = false
    private var sessions: [Session] = []
    private var sort = "new"
    private var category = "0"
    private var level = "0"
    private var tableViewVelocity: CGPoint? = nil
    
    private let filterHeaderViewHeight: CGFloat = 25
    @IBOutlet var filterHeaderView: UIView!
    @IBOutlet weak var filterLabel: UILabel!
    
    @IBOutlet weak var listFilterButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "speaking_tube"))
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 400
        self.tableView.estimatedSectionHeaderHeight = 40
        
        self.refreshControl?.addTarget(self, action: #selector(self.reloadSessions), for: .valueChanged)
        
        Bundle.main.loadNibNamed("sessionFilterHeader", owner: self, options: nil)
        
        self.listFilterButton.target = self
        self.listFilterButton.action = #selector(self.showListFilterPicker)
        
        loadPage(sort: sort, category: category, level: level, page: 1, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let session = sessions[indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellId(session: session), for: indexPath)
        
        if let type = session.type?.lowercased(), type == "banner" {
            return (cell as! BannerCell).update(data: session)
        } else {
            return (cell as! SessionCell).update(data: session)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return filterHeaderView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return filterHeaderViewHeight
    }

    private func loadPage(sort: String, category: String, level: String, page: Int, completion: (() -> Void)?) -> Void {
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
                
                self.filterData(sort, category: category, level: level)
                self.currentPage = page
                self.isLoading = false
                
                if let callback = completion {
                    callback()
                }
            })
        } else if let callback = completion {
            callback()
        }
    }
    
    private func filterData(_ sort: String, category: String, level: String) {
        self.sort = sort
        self.category = category
        self.level = level
        
        let cateService = CategoryService.shared
        let categoryName = cateService.categoryById(category) ?? "All Topics"
        let levelName = cateService.levelById(level) ?? "전체"
        let sortName = cateService.sortById(sort) ?? "최신"
        
        self.filterLabel.text = "\(categoryName) ㆍ \(levelName) ㆍ \(sortName)"
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
                self.loadPage(sort: sort ?? "new", category: category ?? "0", level: level ?? "0", page: 1, completion: nil)
            }
        }
    }
    
    private func cellId(session: Session) -> String {
        if let type = session.type?.lowercased(), type == "banner" {
            return "BannerCell"
        } else {
            return "SessionCell"
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.shouldLoadNext(tableViewVelocity, hasNext: hasNext, isLoading: isLoading) {
            loadPage(sort: sort, category: category, level: level, page: currentPage + 1, completion: nil)
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
        if let channelController = segue.destination as? ChannelController,
            let button = sender as? ChannelButton,
            let session = button.session {
            
            channelController.id = session.channelId
        } else {
            let index = self.tableView.indexPathForSelectedRow?.row
            let session = self.sessions[index!]
            
            if let type = session.type?.lowercased(), type != "banner" {
                let vc = segue.destination as! SessionController
                vc.session = session
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let indexPath = self.tableView.indexPathForSelectedRow,
            let session = self.sessions.get(indexPath.row) {
            
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: session)
        } else {
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: nil)
        }
    }
}

