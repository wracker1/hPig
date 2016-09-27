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

class SessionController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var session: Session? = nil
    
    private var relatedSessions = [Session]()
    
    @IBOutlet weak var sessionImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var basicExButton: UIButton!
    @IBOutlet weak var patternExButton: UIButton!
    @IBOutlet weak var relatedSessionsView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = session?.title
        
        self.sessionImage.clipsToBounds = true
        
        if let item = session {
            ImageDownloadService.shared.get(url: item.image, filter: nil, completionHandler: { (res) in
                self.sessionImage.image = res.result.value
            })
            
            loadRelatedSessions(category: item.category)
        }

        descriptionLabel.text = session?.sessionDescription
        durationLabel.text = session?.duration
        
        basicExButton.layer.cornerRadius = 3
        basicExButton.layer.masksToBounds = true
        
        patternExButton.layer.cornerRadius = 3
        patternExButton.layer.masksToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = (segue.destination as! UINavigationController).topViewController
        
        if let basic = viewController as? BasicStudyController {
            basic.session = session
        } else if let pattern = viewController as? PatternStudyController {
            pattern.session = session
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
