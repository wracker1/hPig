//
//  PatternStudyController.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 26..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class PatternStudyController: UIViewController {

    var session: Session? = nil
    var id: String? = nil
    var part: String? = nil
    var currentIndex = 0
    
    private var patternStudyData = [PatternStudy]()
    private var prevButton: UIBarButtonItem? = nil
    private var nextButton: UIBarButtonItem? = nil
    private var repeatButton: UIBarButtonItem? = nil
    private var saveButton: UIBarButtonItem? = nil
    
    @IBOutlet weak var playerView: hPlayerView!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var koreanLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "패턴학습"
        
        let id = session?.id ?? self.id ?? ""
        let part = Int(session?.part ?? self.part ?? "0")!
        
        englishLabel.text = ""
        koreanLabel.text = ""
        meaningLabel.text = ""
        infoLabel.text = ""
        
        setupToolbar()
        
        playerView.startLoadingIndicator()
        
        play(id: id, part: part, retry: 0)
    }
    
    private func play(id: String, part: Int, retry: Int) {
        if retry < 2 {
            do {
                try playerView.prepareToPlay(id) { (error) in
                    if let cause = error {
                        print(cause)
                        
                        self.play(id: id, part: part, retry: retry + 1)
                    } else {
                        SubtitleService.shared.patternStudyData(id, part: part, currentItem: self.playerView.currentItem(), completion: { (data) in
                            self.patternStudyData = data
                            self.playerView.seekBySlider = self.seekBySlider
                            self.changeLabels(self.currentIndex)
                        })
                    }
                    
                }
            } catch let e {
                print(e)
                
                self.play(id: id, part: part, retry: retry + 1)
            }
        }
    }
    
    private func setupToolbar() {
        self.prevButton = barButtonItem("btn_sub_prev", size: CGSize(width: 74, height: 43), target: self, selector: #selector(self.prevPattern))
        self.nextButton = barButtonItem("btn_sub_next", size: CGSize(width: 74, height: 43), target: self, selector: #selector(self.nextPattern))
        self.repeatButton = barButtonItem("btn_sub_repeat", size: CGSize(width: 43, height: 43), target: self, selector: #selector(self.repeatPattern))
        self.saveButton = barButtonItem("btn_save", size: CGSize(width: 43, height: 43), target: self, selector: #selector(self.savePattern))
        
        let lspace1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let rspace1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        self.navigationController?.isToolbarHidden = false
        self.toolbarItems = [prevButton!, lspace1, repeatButton!, saveButton!, rspace1, nextButton!]
    }
    
    private func changeLabels(_ index: Int) {
        if let data = patternStudyData.get(index), let range = data.timeRange(playerView.currentItemTimeScale()) {
            englishLabel.attributedText = SubtitleService.shared.buildAttributedString(data.english)
            koreanLabel.text = data.korean
            meaningLabel.text = data.meaning
            infoLabel.text = data.info
            
            self.playerView.playInTimeRange(range, completion: { (result) in
                if result {
                    self.currentIndex = index
                    self.playerView.play()
                }
            })
        }
        
        checkSubtitleNavigationButtons(index, length: patternStudyData.count, prevButton: prevButton!, nextButton: nextButton!)
    }
    
    func checkSubtitleNavigationButtons(_ index: Int, length: Int, prevButton: UIBarButtonItem, nextButton: UIBarButtonItem) {
        setButtonState(prevButton, enable: index != 0)
        setButtonState(nextButton, enable: index != (length - 1))
    }
    
    private func setButtonState(_ button: UIBarButtonItem, enable: Bool) {
        button.isEnabled = enable
    }
    
    private func seekBySlider(_ time: CMTime, result: Bool) {
        if result {
            let index = currentIndex(time)
            self.changeLabels(index)
        }
    }
    
    private func currentIndex(_ time: CMTime) -> Int {
        return SubtitleService.shared.currentIndex(time, items: patternStudyData) { (item) -> CMTimeRange? in
            return item.timeRange(self.playerView.currentItemTimeScale())
        }
    }
    
    func prevPattern() {
        changeLabels(currentIndex - 1)
    }
    
    func nextPattern() {
        changeLabels(currentIndex + 1)
    }
    
    func repeatPattern() {
        changeLabels(currentIndex)
    }
    
    func savePattern() {
        if let item = session, let currentPattern = patternStudyData.get(self.currentIndex) {
            let dataService = CoreDataService.shared
            let req: NSFetchRequest<PATTERN> = PATTERN.fetchRequest()
            let userId = AuthenticateService.shared.userId()
            let query = "uid = '\(userId)' AND vid = '\(item.id)' AND part = '\(item.part)' AND position = '\(self.currentIndex)'"
            req.predicate = NSPredicate(format: query)
            
            dataService.select(request: req) { (items, error) in
                let pattern = items.get(0) ?? {
                    let (desc, ctx) = dataService.entityDescription("pattern")
                    return PATTERN(entity: desc!, insertInto: ctx)
                }()
                
                pattern.mutating(userId: userId,
                                 session: item,
                                 pattern: currentPattern,
                                 position: self.currentIndex)
                
                dataService.save()
            }
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        playerView.pause()
    }

}
