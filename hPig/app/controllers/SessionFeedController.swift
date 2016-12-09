//
//  SessionFeedController.swift
//  hPig
//
//  Created by Jesse on 2016. 10. 25..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import Alamofire

class SessionFeedController: UICollectionViewController, UICollectionViewDataSourcePrefetching {

    private var currentPage = 1
    private var hasNext = true
    private var isLoading = false
    private var sessions: [Session] = []
    private var sort = "new"
    private var category = "0"
    private var level = "0"
    private var tableViewVelocity: CGPoint? = nil
    private let minWidth: CGFloat = 375
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "speaking_tube"))
//        self.collectionView!.register(SessionFeedCell.self, forCellWithReuseIdentifier: "sessionFeedCell")
        
        flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        
        loadPage(sort: sort, category: category, level: level, page: currentPage, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sessions.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sessionFeedCell", for: indexPath)
        
        if let feedCell = cell as? SessionFeedCell, let data = sessions.get(indexPath.row) {
            feedCell.update(data: data)
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sessionFeedCell", for: indexPath)
//        
//        if let feedCell = cell as? SessionFeedCell, let data = sessions.get(indexPath.row) {
//            feedCell.update(data: data)
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print(indexPaths)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        NotificationCenter.default.post(name: kViewWillTransition, object: NSValue(cgSize: size))
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
            if let index = self.collectionView?.indexPathsForSelectedItems?.first?.row {
                let session = self.sessions[index]
                
                if let type = session.type?.lowercased(), type != "banner" {
                    let vc = segue.destination as! SessionController
                    vc.session = session
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let index = self.collectionView?.indexPathsForSelectedItems?.first?.row, let session = self.sessions.get(index) {
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: session)
        } else {
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: nil)
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    private func loadPage(sort: String, category: String, level: String, page: Int, completion: (() -> Void)?) -> Void {
        if page == 1 {
            self.hasNext = true
        }
        
        if hasNext && !isLoading {
            
            self.isLoading = true
            
            ApiService.shared.timeLineSessions(sort: sort, category: category, level: level, page: page, completion: { (items) in
                self.hasNext = items.count > 9
                
                //                    let current = self.sessions.count
                
                if page == 1 {
                    self.sessions = items
                    self.collectionView?.reloadData()
                } else {
                    self.sessions += items
                    //                        self.insertRows(from: current, size: items.count)
                }
                
                self.sort = sort
                self.category = category
                self.level = level
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
}
