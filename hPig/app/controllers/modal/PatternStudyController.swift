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
import Toast_Swift

class PatternStudyController: UIViewController {

    var session: Session? = nil
    var currentIndex = 0
    
    private var patternStudyData = [PatternStudy]()
    private var prevButton: UIBarButtonItem? = nil
    private var nextButton: UIBarButtonItem? = nil
    private var repeatButton: UIBarButtonItem? = nil
    private var saveButton: UIBarButtonItem? = nil
    private var startStudyTime: Date? = nil
    
    @IBOutlet weak var playerView: hYTPlayerView!
    @IBOutlet weak var englishLabel: hInteractedLabel!
    @IBOutlet weak var koreanLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var channelButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "패턴학습"
        
        let id = session?.id ?? ""
        let part = Int(session?.part ?? "0")!
        
        englishLabel.text = ""
        englishLabel.viewController = self
        englishLabel.videoPlayer = playerView
        englishLabel.session = session
        
        koreanLabel.text = ""
        meaningLabel.text = ""
        infoLabel.text = ""
        
        if let imageUrl = session?.channelImage {
            ImageDownloadService.shared.decorateChannelButton(self.channelButton, imageUrl: imageUrl)
        }
        
        setupToolbar()
        
        play(id: id, part: part)
        
        playerView.pauseHook = { (time) in
            if self.currentIndex < self.patternStudyData.count {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
                    self.view.presentToast("한 문장씩 따라 읽어 보세요.")
                })
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.startStudyTime = Date()
        
        if let id = session?.id, let part = session?.part {
            NetService.shared.get(path: "/svc/api/video/update/playcnt?id=\(id)&part=\(part)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let time = startStudyTime {
            AuthenticateService.shared.userId(completion: { (userId) in
                let dataService = CoreDataService.shared
                let (entity, ctx) = dataService.entityDescription("time_log")
                let log = TIME_LOG(entity: entity!, insertInto: ctx)
                let vid = self.session?.id ?? ""
                
                log.mutating(userId: userId, vid: vid, startTime: time, type: "pattern")
                dataService.save()
                
                let studySec = Int(time.timeIntervalSinceNow * -1)
                NetService.shared.get(path: "/svc/api/user/update/studytime?id=\(userId)&time=\(studySec)")
            })
        }
        
        playerView.stopVideo()
    }
    
    deinit {
        playerView.stopVideo()
    }
    
    private func play(id: String, part: Int) {
        SubtitleService.shared.patternStudyData(id, part: part, completion: { (data) in
            self.patternStudyData = data
            self.playerView.prepareToPlay(id, completion: { (_, error) in
                if let cause = error {
                    self.view.presentToast("playing video error: \(cause)")
                } else {
                    self.changeLabels(self.currentIndex)
                }
            })
        })
    }
    
    private func setupToolbar() {
        self.prevButton = barButtonItem("btn_sub_prev", size: CGSize(width: 74, height: 43), target: self, selector: #selector(self.prevPattern))
        self.nextButton = barButtonItem("btn_sub_next", size: CGSize(width: 74, height: 43), target: self, selector: #selector(self.nextPattern))
        self.repeatButton = barButtonItem("btn_repeat", size: CGSize(width: 43, height: 43), target: self, selector: #selector(self.repeatPattern))
        self.saveButton = barButtonItem("btn_save", size: CGSize(width: 43, height: 43), target: self, selector: #selector(self.savePattern))
        
        let lspace1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let rspace1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        self.navigationController?.isToolbarHidden = false
        self.toolbarItems = [prevButton!, lspace1, repeatButton!, saveButton!, rspace1, nextButton!]
    }
    
    private func changeLabels(_ index: Int) {
        if let data = patternStudyData.get(index), let range = data.timeRange() {
            englishLabel.attributedText = SubtitleService.shared.buildAttributedString(data.english)
            englishLabel.desc = data.korean
            koreanLabel.text = data.korean
            meaningLabel.text = data.meaning
            infoLabel.text = data.info
            
            self.playerView.playInTimeRange(range, completion: {
                self.currentIndex = index
            })
        }
        
        progressView.progress = Float(index) / Float(patternStudyData.count - 1)
        
        checkSubtitleNavigationButtons(index, length: patternStudyData.count, prevButton: prevButton!, nextButton: nextButton!)
    }
    
    func checkSubtitleNavigationButtons(_ index: Int, length: Int, prevButton: UIBarButtonItem, nextButton: UIBarButtonItem) {
        setButtonState(prevButton, enable: index != 0)
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
            return item.timeRange()
        }
    }
    
    func prevPattern() {
        changeLabels(currentIndex - 1)
    }
    
    func nextPattern() {
        let nextIndex = currentIndex + 1
        
        if nextIndex < patternStudyData.count {
            changeLabels(currentIndex + 1)
        } else {
            presentAlert()
        }
    }
    
    func repeatPattern() {
        changeLabels(currentIndex)
    }
    
    func savePattern() {
        if let item = session, let currentPattern = patternStudyData.get(self.currentIndex) {
            AuthenticateService.shared.userId(completion: { (userId) in
                let dataService = CoreDataService.shared
                let req: NSFetchRequest<PATTERN> = PATTERN.fetchRequest()
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
                    
                    self.view.presentToast("저장 하였습니다.\n학습 정보에서 확인 해보세요.")
                }
            })
        }
        
        
    }
    
    private func presentAlert() {
        let alert = UIAlertController(title: "Good job!",
                                      message: "해당 영상에 대한 패턴학습을 완료하셨습니다.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "닫기", style: .default, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "완료", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let channelMain = segue.destination as? ChannelController {
            channelMain.id = session?.channelId
        }
    }

}
