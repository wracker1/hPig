//
//  MyInfoController.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 21..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import AlamofireImage
import CoreGraphics
import CoreData

class MyInfoController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var passNameLabel: UILabel!
    @IBOutlet weak var passDurationLabel: UILabel!
    @IBOutlet weak var studyTotalDurationView: UIView!
    @IBOutlet weak var totalDurationLabel: UILabel!
    @IBOutlet weak var numberOfVideoLabel: UILabel!
    @IBOutlet weak var historyCollectionView: UICollectionView!
    @IBOutlet weak var historySegControl: UISegmentedControl!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    private var histories = [HISTORY]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studyTotalDurationView.layer.cornerRadius = 5.0
        studyTotalDurationView.layer.borderColor = UIColor.lightGray.cgColor
        studyTotalDurationView.layer.borderWidth = 1.0
        
        let ratio: CGFloat = 0.85
        let margin: CGFloat = 18
        let width = (view.bounds.size.width / 2) - margin
        
        flowLayout.itemSize = CGSize(width: width, height: width * ratio)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AuthenticateService.shared.user { (user) in
            self.loadPersonalInfoView(user)
            
            let id = user?.id ?? Global.guestId
            let logReq: NSFetchRequest<TIME_LOG> = TIME_LOG.fetchRequest()
            logReq.predicate = NSPredicate(format: "uid = '\(id)'")
            
            CoreDataService.shared.select(request: logReq) { (items, error) in
                self.loadStudyTimeInfoView(logs: items)
            }
        }
        
        historySegChanged(historySegControl)
    }
    
    @IBAction func historySegChanged(_ sender: UISegmentedControl) {
        AuthenticateService.shared.user { (user) in
            let id = user?.id ?? Global.guestId
            let historyReq: NSFetchRequest<HISTORY> = HISTORY.fetchRequest()
            historyReq.sortDescriptors = [NSSortDescriptor(key: "lastdate", ascending: false)]
            
            switch sender.selectedSegmentIndex {
            case 1:
                historyReq.predicate = NSPredicate(format: "uid = '\(id)' AND position != maxposition")
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
    
    private func loadPersonalInfoView(_ user: User?) {
        let name = user?.name ?? "게스트"
        let id = user?.id ?? Global.guestId
        let url = user?.profileImage ?? "https://ssl.pstatic.net/static/pwe/address/nodata_45x45.gif"
        
        nameLabel.text = "\(name) 님"
        idLabel.text = "| \(id)"
        
        ImageDownloadService.shared.get(
            url: url,
            filter: nil,
            completionHandler: { (res) in
                if let image = res.result.value {
                    self.profileImageView.image = image
                }
        })
    }
    
    private func loadStudyTimeInfoView(logs: [TIME_LOG]) {
        var totalTime: Double = 0
        var vids = Set<String>()
        
        logs.forEach({ (log) in
            totalTime += log.studytime
            
            if let vid = log.vid {
                vids.insert(vid)
            }
        })
        
        totalDurationLabel.text = secondsToHoursMinutesSeconds(seconds: Int(totalTime))
        numberOfVideoLabel.text = "\(vids.count)개"
    }
    
    private func secondsToHoursMinutesSeconds(seconds : Int) -> String {
        let h = String(format: "%02d", seconds / 3600)
        let m = String(format: "%02d", (seconds % 3600) / 60)
        let s = String(format: "%02d", (seconds % 3600) % 60)
        return "\(h):\(m):\(s)"
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = (segue.destination as! UINavigationController).topViewController,
            let basic = viewController as? BasicStudyController,
            let cell = sender as? StudyHistoryCell,
            let history = cell.history {
            
            basic.session = Session(history)
            basic.currentIndex = Int(history.position ?? "0")!
        }
    }
    
    @IBAction func returnedFromBasicStudy(segue: UIStoryboardSegue) {
        
    }
}
