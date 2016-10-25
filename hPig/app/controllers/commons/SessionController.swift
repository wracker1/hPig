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
    
    @IBOutlet weak var mainScroller: UIScrollView!
    @IBOutlet weak var channelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sessionImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var basicExButton: UIButton!
    @IBOutlet weak var patternExButton: UIButton!
    @IBOutlet weak var relatedSessionsView: UICollectionView!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "세션"
        self.titleLabel.text = session?.title
        
        self.sessionImage.clipsToBounds = true
        
        if let item = session {
            self.sessionImage.image = nil
            
            if let imageUrl = item.image {
                ImageDownloadService.shared.get(url: imageUrl, filter: nil, completionHandler: { (res) in
                    self.sessionImage.image = res.result.value
                })
            }
            
            if let channelImage = item.channelImage {
                ImageDownloadService.shared.get(url: channelImage, filter: nil, completionHandler: { (res) in
                    self.channelButton.imageView?.layer.cornerRadius = 20.0
                    
                    self.channelButton.setImage(res.result.value, for: .normal)
                })
            }
            
            if let category = item.category {
                loadRelatedSessions(category: category)
            }
            
            SubtitleService.shared.subtitleData(item.id, part: Int(item.part) ?? 0, completion: { (data) in
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
    
    private func loadHistory(session: Session) {
        AuthenticateService.shared.userId { (userId) in
            let req: NSFetchRequest<HISTORY> = HISTORY.fetchRequest()
            
            let query = "uid = '\(userId)' AND vid = '\(session.id)' AND part = '\(session.part)'"
            req.predicate = NSPredicate(format: query)
            
            CoreDataService.shared.select(request: req) { (items, error) in
                let hasHistory = items.count > 0
                self.continueButton.isHidden = !hasHistory
                
                if let history = items.first {
                    let position = Int(history.position)
                    let maxPosition = Int(history.maxposition)
                    
                    let value = Float(position) / Float(maxPosition)
                    self.progress.progress = value
                    self.latestStudyPosition = position
                }
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
    
    @IBAction func returnedFromBasicStudy(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func returnedFromPatternStudy(segue: UIStoryboardSegue) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let item = session {
            loadHistory(session: item)
        }
    }
    
    override func viewWillLayoutSubviews() {
//        LayoutService.shared.adjustContentSize(mainScroller, subScroller: relatedSessionsView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigator = segue.destination as? UINavigationController {
            if let basic = navigator.topViewController as? BasicStudyController {
                basic.session = session
                
                if let button = sender as? UIButton, button == continueButton {
                    basic.currentIndex = latestStudyPosition
                }
            } else if let pattern = navigator.topViewController as? PatternStudyController {
                pattern.session = session
            }
        } else if let sessionController = segue.destination as? SessionController, let cell = sender as? RelatedSessionCell {
            sessionController.session = cell.session
        } else if let channelController = segue.destination as? ChannelController, let item = session {
            channelController.id = item.channelId
        }
    }
    
    
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let indexPaths = relatedSessionsView.indexPathsForSelectedItems,
            let indexPath = indexPaths.first,
            let session = self.relatedSessions.get(indexPath.row) {
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: session)
        } else {
            return AuthenticateService.shared.shouldPerform(identifier, viewController: self, sender: sender, session: session)
        }
    }
}
