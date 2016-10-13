//
//  SessionController.swift
//  hPig
//
//  Created by 이동현 on 2016. 9. 25..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import CoreGraphics
import CoreData

class SessionController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var session: Session? = nil
    
    private var relatedSessions = [Session]()
    private var latestStudyPosition = 0
    
    @IBOutlet weak var sessionImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var basicExButton: UIButton!
    @IBOutlet weak var patternExButton: UIButton!
    @IBOutlet weak var relatedSessionsView: UICollectionView!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var continueButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = session?.title
        
        self.sessionImage.clipsToBounds = true
        
        if let item = session {
            self.sessionImage.image = nil
            
            ImageDownloadService.shared.get(url: item.image, filter: nil, completionHandler: { (res) in
                self.sessionImage.image = res.result.value
            })
            
            loadRelatedSessions(category: item.category)
            
            SubtitleService.shared.subtitleData(item.id, part: Int(item.part) ?? 0, currentItem: nil, completion: { (data) in
                if let subtitle = data.first, let range = subtitle.timeRange {
                    self.startTimeLabel.text = TimeFormatService.shared.timeStringFromCMTime(time: range.start)
                }
            })
        }

        descriptionLabel.text = session?.sessionDescription
        durationLabel.text = session?.duration
        
        basicExButton.layer.cornerRadius = 3
        basicExButton.layer.masksToBounds = true
        
        patternExButton.layer.cornerRadius = 3
        patternExButton.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let item = session {
            loadHistory(session: item)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = (segue.destination as! UINavigationController).topViewController
        
        if let basic = viewController as? BasicStudyController {
            basic.session = session
            
            if let button = sender as? UIButton, button == continueButton {
                basic.currentIndex = latestStudyPosition
            }
            
        } else if let pattern = viewController as? PatternStudyController {
            pattern.session = session
        }
    }
    
    private func loadHistory(session: Session) {
        let req: NSFetchRequest<HISTORY> = HISTORY.fetchRequest()
        let userId = AuthenticateService.shared.userId()
        let query = "uid = '\(userId)' AND vid = '\(session.id)' AND part = '\(session.part)'"
        req.predicate = NSPredicate(format: query)
        
        CoreDataService.shared.select(request: req) { (items, error) in
            let hasHistory = items.count > 0
            self.continueButton.isHidden = !hasHistory
            
            if let history = items.first,
                let pos = history.position,
                let maxPos = history.maxposition,
                let position = Int(pos),
                let maxPosition = Int(maxPos) {
                
                let value = Float(position) / Float(maxPosition)
                self.progress.progress = value
                self.latestStudyPosition = position
            }
        }
    }
    
    private func loadRelatedSessions(category: String) {
        NetService.shared.getCollection(path: "/svc/api/list/new/\(category)/0/1") { (res: DataResponse<[Session]>) in
            if let current = self.session, let items = res.result.value?.filter({ (item) -> Bool in
                return item.status == "Y" && item.id != current.id
            }) {
                self.relatedSessions = items
                self.relatedSessionsView.reloadData()
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return relatedSessions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "relatedSessionView", for: indexPath) as! RelatedSessionCell
        
        if let session = relatedSessions.get(indexPath.row) {
            cell.update(session: session)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let session = relatedSessions.get(indexPath.row), let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SessionController") as? SessionController {
            viewController.session = session
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func returnedFromBasicStudy(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func returnedFromPatternStudy(segue: UIStoryboardSegue) {
        
    }

}
