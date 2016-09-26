//
//  PatternStudyController.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 26..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import AVFoundation

class PatternStudyController: UIViewController {

    var session: Session? = nil
    
    private var patternStudyData = [PatternStudy]()
    private var prevButton: UIBarButtonItem? = nil
    private var nextButton: UIBarButtonItem? = nil
    private var repeatButton: UIBarButtonItem? = nil
    private var saveButton: UIBarButtonItem? = nil
    private var currentIndex = 0
    
    @IBOutlet weak var playerView: hPlayerView!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var koreanLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "패턴학습"
        
        let id = session?.id ?? ""
        let part = Int(session?.part ?? "0")!
        
        englishLabel.text = ""
        koreanLabel.text = ""
        meaningLabel.text = ""
        infoLabel.text = ""
        
        setupToolbar()
        
        playerView.startLoadingIndicator()
        
        playerView.prepareToPlay(id) { (error) in
            if let cause = error {
                print(cause)
            } else {
                SubtitleService.shared.patternStudyData(id, part: part, currentItem: self.playerView.currentItem(), completion: { (data) in
                    let index = 0
                    self.patternStudyData = data
                    self.playerView.seekBySlider = self.seekBySlider
                    self.changeLabels(index)
                })
            }
            
        }
    }
    
    private func setupToolbar() {
        self.prevButton = barButtonItem("btn_sub_prev", size: CGSizeMake(74, 43), target: self, selector: #selector(self.prevPattern))
        self.nextButton = barButtonItem("btn_sub_next", size: CGSizeMake(74, 43), target: self, selector: #selector(self.nextPattern))
        self.repeatButton = barButtonItem("btn_sub_repeat", size: CGSizeMake(43, 43), target: self, selector: #selector(self.repeatPattern))
        self.saveButton = barButtonItem("btn_save", size: CGSizeMake(43, 43), target: self, selector: #selector(self.savePattern))
        
        let lspace1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let rspace1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        self.navigationController?.isToolbarHidden = false
        self.toolbarItems = [prevButton!, lspace1, repeatButton!, saveButton!, rspace1, nextButton!]
    }
    
    private func changeLabels(_ index: Int) {
        if let data = patternStudyData.get(index), let range = data.timeRange {
            if let english = data.english, let korean = data.korean {
                englishLabel.attributedText = SubtitleService.shared.buildAttributedString(english)
                koreanLabel.text = korean
            }
            
            if let meaning = data.meaning, let info = data.info {
                meaningLabel.text = meaning
                infoLabel.text = info
            }
            
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
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        playerView.pause()
    }

}
