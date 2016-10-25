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
        
        NotificationCenter.default.post(name: Global.kViewWillTransition, object: NSValue(cgSize: size))
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
            
            NetService.shared.getCollection(path: "/svc/api/list/\(sort)/\(category)/\(level)/\(page)", completionHandler: { (res: DataResponse<[Session]>) in
                
                if let items = res.result.value?.filter({ (session) -> Bool in
                    return session.status == "Y"
                }) {
                    self.hasNext = items.count > 9
                    
//                    let current = self.sessions.count
                    
                    if page == 1 {
                        self.sessions = items
                        self.collectionView?.reloadData()
                    } else {
                        self.sessions += items
//                        self.insertRows(from: current, size: items.count)
                    }
                }
                
                if let callback = completion {
                    callback()
                }
                
                self.sort = sort
                self.category = category
                self.level = level
                self.currentPage = page
                self.isLoading = false
            })
        } else if let callback = completion {
            callback()
        }
    }
}
