//
//  BasicStudyController.swift
//  speaking-tube
//
//  Created by Jesse on 2016. 8. 12..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreData
import CoreGraphics

class BasicStudyController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var session: Session? = nil
    var currentIndex = 0
    var startTime: Float = 0.0
    
    private var subtitles = [BasicStudy]()
    private let timeRangePadding = Float64(0.1)
    
    private var useAutoScroll = true
    private var isActiveEnglish = true
    private var isActiveKorean = true
    private var isActiveSubtitles = false
    private var isPresentingAlert = false
    private var needToStopOnPlaying = false
    
    private var btnKorean: UIBarButtonItem? = nil
    private var btnEnglish: UIBarButtonItem? = nil
    private var btnSubtitles: UIBarButtonItem? = nil
    private var btnReading: UIBarButtonItem? = nil
    private var startStudyTime: Date? = nil
    private var endTimer: Timer? = nil
    private var duration: CMTime? = nil
    
    @IBOutlet weak var channelButton: UIButton!
    @IBOutlet weak var playerView: hYTPlayerView!
    @IBOutlet weak var subtitleTableView: UITableView!
    @IBOutlet weak var currentSubtitleView: UIView!
    @IBOutlet weak var sessionControlView: hSessionControlView!
    
    @IBOutlet weak var englishSubLabel: hInteractedLabel!
    @IBOutlet weak var koreanSubLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "기본학습"
        self.subtitleTableView.delegate = self
        self.subtitleTableView.dataSource = self
        self.subtitleTableView.rowHeight = UITableViewAutomaticDimension
        self.subtitleTableView.estimatedRowHeight = 50
        
        englishSubLabel.viewController = self
        englishSubLabel.videoPlayer = playerView
        englishSubLabel.session = session
        englishSubLabel.text = ""
        koreanSubLabel.text = ""
        
        setupToolbar()
        
        let id = session?.id ?? ""
        let part = Int(session?.part ?? "0")!
        
        playerView.ticker = changeSubtitle

        play(id: id, part: part)
        
        if let channelImage = session?.channelImage {
            ImageDownloadService.shared.decorateChannelButton(self.channelButton, imageUrl: channelImage)
        }
        
        playerView.pauseHook = { (time) in
            if self.currentIndex < self.subtitles.count {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
                    self.view.presentToast("한 문장씩 따라 읽어 보세요.")
                })
            }
        }
        
        sessionControlView.repeatButton.addTarget(self, action: #selector(self.repeatCurrentIndex), for: .touchUpInside)
        sessionControlView.prevButton.addTarget(self, action: #selector(self.playPrevIndex), for: .touchUpInside)
        sessionControlView.nextButton.addTarget(self, action: #selector(self.playNextIndex), for: .touchUpInside)
    }
    
    func repeatCurrentIndex() {
        playAtIndex(currentIndex)
    }
    
    func playPrevIndex() {
        playAtIndex(currentIndex - 1)
    }
    
    func playNextIndex() {
        playAtIndex(currentIndex + 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.startStudyTime = Date()
        self.isPresentingAlert = false
        
        if let id = session?.id, let part = session?.part {
            NetService.shared.get(path: "/svc/api/video/update/playcnt?id=\(id)&part=\(part)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let timer = endTimer, timer.isValid {
            timer.invalidate()
        }
        
        if let time = startStudyTime {
            AuthenticateService.shared.userId(completion: { (userId) in
                let (entity, ctx) = CoreDataService.shared.entityDescription("time_log")
                let log = TIME_LOG(entity: entity!, insertInto: ctx)
                let id = self.session?.id ?? ""
                
                log.mutating(userId: userId, vid: id, startTime: time, type: "basic")
                CoreDataService.shared.save()
            
                let studySec = Int(time.timeIntervalSinceNow * -1)
                NetService.shared.get(path: "/svc/api/user/update/studytime?id=\(userId)&time=\(studySec)")
            })
        }
        
        playerView.stopVideo()
        saveStudyLog()
    }
    
    private func saveStudyLog() {
        if let item = session {
            AuthenticateService.shared.userId(completion: { (userId) in
                let req: NSFetchRequest<HISTORY> = HISTORY.fetchRequest()
                let query = "uid = '\(userId)' AND vid = '\(item.id)' AND part = '\(item.part)'"
                req.predicate = NSPredicate(format: query)
                
                CoreDataService.shared.select(request: req) { (items, error) in
                    self.playerView.currentCMTime(completion: { (currentTime) in
                        let history = items.get(0) ?? {
                            let (desc, ctx) = CoreDataService.shared.entityDescription("history")
                            return HISTORY(entity: desc!, insertInto: ctx)
                            }()
                        
                        let currentIndex = self.currentIndex(currentTime)
                        let seconds = TimeFormatService.shared.secondsFromCMTime(time: currentTime)
                        
                        history.mutating(userId: userId,
                                         session: item,
                                         date: NSDate(),
                                         studyTime: seconds,
                                         position: currentIndex,
                                         maxPosition: self.subtitles.count - 1)
                        
                        CoreDataService.shared.save()
                    })
                }
            })
        }
    }
    
    private func play(id: String, part: Int) {
        let service = TimeFormatService.shared
        
        playerView.prepareToPlay(id, completion: { (sec, error) in
            if let cause = error {
                self.view.presentToast("playing video error: \(cause)")
            } else {
                let endTime = service.timeFromFloat(seconds: sec)
                let time = service.timeStringFromCMTime(time: endTime)
                self.duration = endTime

                SubtitleService.shared.subtitleData(id, part: part, duration: time, completion: { (data) in
                    self.subtitles = data
                    self.subtitleTableView.reloadData()
                    
                    if self.startTime > 0.0 {
                        self.playerView.seek(toTime: service.timeFromFloat(seconds: self.startTime))
                    } else if let sub = data.get(self.currentIndex), let range = sub.timeRange() {
                        self.playerView.seek(toTime: range.start)
                    }
                    
                    if let endStartTime = self.subtitles.last?.startTime, let lastStartTime = service.stringToCMTime(endStartTime) {
                        let diff = endTime - lastStartTime
                        self.needToStopOnPlaying = service.secondsFromCMTime(time: diff) > 3.0
                    }
                })
            }
        })
    }
    
    func seekBySlider(_ time: CMTime, result: Bool) {
        if result {
            let btnSwitch = self.btnReading!.customView! as! UISwitch
            
            if btnSwitch.isOn {
                let index = currentIndex(time)
                
                if let subtitle = subtitles.get(index), let timeRange = subtitle.timeRange() {
                    playerView.playRange = timeRange
                    self.currentIndex = index
                }
            }
            
            self.changeSubtitle(time)
        }
    }
    
    private func buttonInteractionEnabled(_ button: UIButton, enabled: Bool) {
        button.isUserInteractionEnabled = enabled
    }
    
    private func playAtTime(_ time: CMTime) {
        playerView.seek(toTime: time)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let channelMain = segue.destination as? ChannelController {
           channelMain.id = session?.channelId
        }
    }
    
    private func setupToolbar() {
        self.btnKorean = barButtonItem("btn_korean_on", size: CGSize(width: 30, height: 30), target: self, selector: #selector(self.toggleKoreanSubtitle(sender:)))
        self.btnEnglish = barButtonItem("btn_english_on", size: CGSize(width: 30, height: 30), target: self, selector: #selector(self.toggleEnglishSubtitle(sender:)))
        self.btnSubtitles = barButtonItem("btn_subtitles_off", size: CGSize(width: 31, height: 35), target: self, selector: #selector(self.toggleSubtitlesView(sender:)))
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let label = UILabel()
        label.text = "따라읽기"
        label.sizeToFit()
        
        let btnSwitch = UISwitch()
        btnSwitch.tintColor = UIColor.white
        btnSwitch.onTintColor = RGBA(190, g: 22, b: 31, a: 1.0)
        btnSwitch.addTarget(self, action: #selector(self.toggleSelfReading(sender:)), for: .valueChanged)
        self.btnReading = UIBarButtonItem(customView: btnSwitch)
        
        self.navigationController?.isToolbarHidden = false
        self.toolbarItems = [btnKorean!, btnEnglish!, btnSubtitles!, space, UIBarButtonItem(customView: label), btnReading!]
    }
    
    func toggleSelfReading(sender: UISwitch) {
        if sender.isOn {
            self.sessionControlView.alpha = 1.0
            playerView.currentCMTime(completion: { (currentTime) in
                let index = self.currentIndex(currentTime)
                self.currentIndex = index
                
                if let subtitle = self.subtitles.get(index), let timeRange = subtitle.timeRange() {
                    self.playerView.playRange = timeRange
                }
            })
        } else {
            self.sessionControlView.alpha = 0.0
            playerView.playRange = nil
        }
    }
    
    private func playAtIndex(_ index: Int) {
        if let subtitle = subtitles.get(index), let timeRange = subtitle.timeRange() {
            let range = CMTimeRange(start: timeRange.start - preTimeMargin, end: timeRange.end + postTimeMargin)
            
            playerView.playInTimeRange(range, completion: { (result) in
                self.showCaption(at: index)
            })
        }
    }
    
    private func showCaption(at index: Int) {
        self.currentIndex = index
        
        if let subtitle = subtitles.get(index) {
            self.englishSubLabel.text = subtitle.english
            self.englishSubLabel.desc = subtitle.korean
            self.koreanSubLabel.text = subtitle.korean
            
            if useAutoScroll {
                let indexPath = IndexPath(row: index, section: 0)
                self.subtitleTableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                NotificationCenter.default.post(name: kSelectCellWithIndexPath, object: nil, userInfo: ["indexPath": indexPath])
            }
        }
        
        let maxIndex = subtitles.count - 1
        progressView.progress = Float(index) / Float(maxIndex)
        
        checkSubtitleNavigationButtons(
            index,
            length: subtitles.count,
            prevButton: sessionControlView.prevButton,
            nextButton: sessionControlView.nextButton
        )
    }
    
    func currentIndex(_ time: CMTime) -> Int {
        return SubtitleService.shared.currentIndex(time, items: self.subtitles, rangeBlock: { (sub) -> CMTimeRange? in
            return sub.timeRange()
        })
    }
    
    private func changeSubtitle(_ time: CMTime, playing: Bool = true) {
        let index = currentIndex(time)
        let maxIndex = subtitles.count - 1
        let isEndIndex = index == maxIndex
        
        if let sw = btnReading?.customView as? UISwitch, !sw.isOn {
            showCaption(at: index)
        }
        
        if playing {
            if isEndIndex && !isPresentingAlert && needToStopOnPlaying{
                self.endTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (_) in
                    self.endStudy()
                })
            }
        } else {
            endStudy()
        }
    }
    
    private func endStudy() {
        if !isPresentingAlert {
            isPresentingAlert = true
            
            playerView.pauseVideo()
            
            presentAlert()
        }
    }
    
    private func presentAlert() {
        let alert = UIAlertController(title: "기본학습 완료", message: "해당영상에 대한 기본학습은 완료하셨습니다. 패턴학습을 통해 중요한 문장을 복습해보세요.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "나중에 하기", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "패턴학습", style: .default, handler: { (_) in
            let item = self.session
            
            if let presentingViewController = presentController(viewController: self) {
                self.dismiss(animated: true, completion: {
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (_) in
                        if let navigator = UIStoryboard(name: "PatternStudy", bundle: Bundle.main).instantiateInitialViewController() as? UINavigationController,
                            let patternStudyController = navigator.topViewController as? PatternStudyController {
                            
                            patternStudyController.session = item
                            presentingViewController.present(navigator, animated: true, completion: nil)
                        }
                    })
                })
            }
        }))
        
        alert.messageLabel()?.textAlignment = .left

        self.present(alert, animated: true, completion: nil)
    }
    
    func checkSubtitleNavigationButtons(_ index: Int, length: Int, prevButton: UIButton, nextButton: UIButton) {
        setButtonState(prevButton, enable: index != 0)
        setButtonState(nextButton, enable: index != (length - 1))
    }
    
    private func setButtonState(_ button: UIButton, enable: Bool) {
        button.isUserInteractionEnabled = enable
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subtitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subtitle = self.subtitles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath) as! SubtitleCell
        cell.update(subtitle, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selfReadingButton = btnReading?.customView as? UISwitch, selfReadingButton.isOn {
            playAtIndex(indexPath.row)
        } else {
            let subtitle = self.subtitles[indexPath.row]
            
            if let time = subtitle.timeRange() {
                playerView.seek(toTime: time.start)
            }
        }
     
        NotificationCenter.default.post(name: kSelectCellWithIndexPath, object: nil, userInfo: ["indexPath": indexPath])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        useAutoScroll = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { (_) in
                self.useAutoScroll = true
            })
        }
    }
    
    func toggleSubtitlesView(sender: AnyObject) {
        isActiveSubtitles = !isActiveSubtitles
        
        if let btn = btnSubtitles?.customView as? UIButton {
            if isActiveSubtitles {
                self.currentSubtitleView.isHidden = true
                self.subtitleTableView.isHidden = false
                btn.setImage(UIImage(named: "btn_subtitles_on"), for: .normal)
            } else {
                self.currentSubtitleView.isHidden = false
                self.subtitleTableView.isHidden = true
                btn.setImage(UIImage(named: "btn_subtitles_off"), for: .normal)
            }
        }
    }
    
    func toggleKoreanSubtitle(sender: AnyObject) {
        isActiveKorean = !isActiveKorean
        
        koreanSubLabel.isHidden = !isActiveKorean
        
        if let btn = btnKorean?.customView as? UIButton {
            if isActiveKorean {
                btn.setImage(UIImage(named: "btn_korean_on"), for: .normal)
            } else {
                btn.setImage(UIImage(named: "btn_korean_off"), for: .normal)
            }
        }
        
        NotificationCenter.default.post(name: kToggleKoreanLabelVisible, object: nil, userInfo: ["value": isActiveKorean])
    }
    
    func toggleEnglishSubtitle(sender: AnyObject) {
        isActiveEnglish = !isActiveEnglish
        
        englishSubLabel.isHidden = !isActiveEnglish
        
        if let btn = btnEnglish?.customView as? UIButton {
            if isActiveEnglish {
                btn.setImage(UIImage(named: "btn_english_on"), for: .normal)
            } else {
                btn.setImage(UIImage(named: "btn_english_off"), for: .normal)
            }
        }
        
        NotificationCenter.default.post(name: kToggleEnglishLabelVisible, object: nil, userInfo: ["value": isActiveEnglish])
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
  
