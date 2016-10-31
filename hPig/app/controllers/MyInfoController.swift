//
//  MyInfoController.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import AlamofireImage
import CoreData

class MyInfoController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var historyCollectionView: UICollectionView!
    
    private var histories = [HISTORY]()
    private var infoHeader: MyInfoHeaderCell? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "학습 현황"
        
        let ratio: CGFloat = 0.85
        let margin: CGFloat = 18
        let width = (view.bounds.size.width / 2) - margin
        
        flowLayout.itemSize = CGSize(width: width, height: width * ratio)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadUserData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return histories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "studyHistoryCell", for: indexPath) as! StudyHistoryCell
        
        if let history = histories.get(indexPath.row) {
            cell.update(history: history)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let item = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                               withReuseIdentifier: "myInfoHeaderView",
                                                               for: indexPath)
    
        if let header = item as? MyInfoHeaderCell {
            self.initInfoHeader(header)
        }
        
        return item
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = (segue.destination as! UINavigationController).topViewController,
            let basic = viewController as? BasicStudyController,
            let cell = sender as? StudyHistoryCell,
            let history = cell.history {
            
            basic.session = Session(history)
            basic.currentIndex = Int(history.position)
        } else {
            AuthenticateService.shared.prepare(self, for: segue, sender: sender)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let indexPaths = historyCollectionView.indexPathsForSelectedItems,
            let indexPath = indexPaths.first,
            let history = histories.get(indexPath.row),
            let session = Session(history) {
            
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: session)
        } else {
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: nil)
        }
    }
    
    private func initInfoHeader(_ header: MyInfoHeaderCell) {
        if self.infoHeader == nil {
            self.infoHeader = header
            
            header.viewController = self
            header.historySegControl.addTarget(self, action: #selector(self.historySegChanged(_:)), for: .valueChanged)
            
            loadUserData()
        }
    }
    
    private func loadUserData() {
        if let header = infoHeader {
            AuthenticateService.shared.user { (user) in
                header.loadUserInfo(user)
                self.historySegChanged(header.historySegControl)
            }
        }
    }
    
    func historySegChanged(_ sender: UISegmentedControl) {
        AuthenticateService.shared.user { (user) in
            let id = user?.id ?? Global.guestId
            let historyReq: NSFetchRequest<HISTORY> = HISTORY.fetchRequest()
            historyReq.sortDescriptors = [NSSortDescriptor(key: "lastdate", ascending: false)]
            
            switch sender.selectedSegmentIndex {
            case 1:
                historyReq.predicate = NSPredicate(format: "uid = '\(id)' AND position < maxposition")
            case 2:
                historyReq.predicate = NSPredicate(format: "uid = '\(id)' AND position == maxposition")
            default:
                historyReq.predicate = NSPredicate(format: "uid = '\(id)'")
            }
            
            CoreDataService.shared.select(request: historyReq) { (items, error) in
                self.histories = items
                self.historyCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func returnedFromBasicStudy(segue: UIStoryboardSegue) {
        
    }
}
