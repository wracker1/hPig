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

class SessionController: UIViewController {
    var session: Session? = nil
    
    @IBOutlet weak var sessionImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var relatedContentsScroller: UIScrollView!
    @IBOutlet weak var basicExButton: UIButton!
    @IBOutlet weak var patternExButton: UIButton!
    @IBOutlet weak var relatedContentsView: UIStackView!

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
        }
        
//        else if let pattern = viewController as? PatternStudyController {
//            pattern.session = session
//        }
    }
    
    private func loadRelatedSessions(category: String) {
        NetService.shared.getCollection(path: "/svc/api/list/new/\(category)/0/1") { (res: DataResponse<[Session]>) in
            if let current = self.session, let items = res.result.value?.filter({ (item) -> Bool in
                return item.status == "Y" && item.id != current.id
            }) {
                self.appendRelatedSessions(sessions: items)
            }
        }
    }
    
    private func appendRelatedSessions(sessions: [Session]) {
//        relatedContentsView.subviews.enumerated().forEach { (i, view) in
//            if let button = view as? hRelatedSessionButton {
//                button.addTarget(self, action: #selector(self.didSelectRelatedSessionButton(button:)), for: .touchUpInside)
//                if i < sessions.count {
//                    let session = sessions[i]
//
//                    button.update(session: session)
//                } else {
//                    button.isHidden = true
//                }
//            }
//        }
    }
    
    func didSelectRelatedSessionButton(button: hRelatedSessionButton) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SessionController") as? SessionController {
            viewController.session = button.session
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func returnedFromBasicStudy(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func returnedFromPatternStudy(segue: UIStoryboardSegue) {
        
    }

}
