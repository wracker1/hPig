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

class BasicStudyController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var session: Session? = nil
    
    private var subtitles = [BasicStudy]()
    private var currentIndex = 0
    private let timeRangePadding = Float64(0.1)
    
    private var useAutoScroll = true
    private var isActiveEnglish = true
    private var isActiveKorean = true
    private var isActiveSubtitles = false
    
    private var btnKorean: UIBarButtonItem? = nil
    private var btnEnglish: UIBarButtonItem? = nil
    private var btnSubtitles: UIBarButtonItem? = nil
    private var btnReading: UIBarButtonItem? = nil
    private var selectedCell: SubtitleCell? = nil
    
    @IBOutlet weak var playerView: hPlayerView!
    @IBOutlet weak var subtitleTableView: UITableView!
    @IBOutlet weak var currentSubtitleView: UIView!
    @IBOutlet weak var sessionControlView: hSessionControlView!
    
    @IBOutlet weak var englishSubLabel: UILabel!
    @IBOutlet weak var koreanSubLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "기본학습"
        self.subtitleTableView.delegate = self
        self.subtitleTableView.dataSource = self
        self.subtitleTableView.rowHeight = UITableViewAutomaticDimension
        self.subtitleTableView.estimatedRowHeight = 50
        
        englishSubLabel.text = ""
        koreanSubLabel.text = ""
        
        setupToolbar()
        
        let id = session?.id ?? ""
        let part = Int(session?.part ?? "0")!
        
        playerView.startLoadingIndicator()
        
        play(id: id, part: part, retry: 0)
        
        sessionControlView.repeatButton.addTarget(self, action: #selector(self.repeatCurrentIndex), for: .touchUpInside)
        sessionControlView.prevButton.addTarget(self, action: #selector(self.playPrevIndex), for: .touchUpInside)
        sessionControlView.nextButton.addTarget(self, action: #selector(self.playNextIndex), for: .touchUpInside)
    }
    
    private func saveStudyLog() {
        let dataService = CoreDataService.shared
        
        if let item = session, let current = playerView.currentTime() {
            let req: NSFetchRequest<HISTORY> = HISTORY.fetchRequest()
            let userId = AuthenticateService.shared.userId()
            let query = "uid = '\(userId)' AND vid = '\(item.id)' AND part = '\(item.part)'"
            req.predicate = NSPredicate(format: query)
                
            dataService.select(request: req) { (items, error) in
                let history = items.get(0) ?? {
                    let (desc, ctx) = dataService.entityDescription("history")
                    return HISTORY(entity: desc!, insertInto: ctx)
                }()
                
                let currentSeconds = TimeFormatService.shared.secondsFromCMTime(time: current)
                history.mutating(userId: userId, session: item, date: NSDate(), studyTime: currentSeconds)
                
                CoreDataService.shared.save()
            }
        }
    }
    
    private func play(id: String, part: Int, retry: Int) {
        if retry < 2 {
            do {
                try playerView.prepareToPlay(id) { (error) in
                    if let cause = error {
                        print(cause)
                        
                        self.play(id: id, part: part, retry: retry + 1)
                    } else {
                        SubtitleService.shared.subtitleData(id, part: part, currentItem: self.playerView.currentItem()) { (data) in
                            self.subtitles = data
                            self.subtitleTableView.reloadData()
                            self.playerView.ticker = self.changeSubtitle
                            self.playerView.seekBySlider = self.seekBySlider
                            
                            if let sub = data.get(0), let range = sub.timeRange {
                                self.playerView.seekToTime(range.start, completionHandler: { (result) in
                                    self.playerView.play()
                                })
                            }
                        }
                    }
                }
            } catch let e {
                print(e)
                
                self.play(id: id, part: part, retry: retry + 1)
            }
        }
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
    
    func seekBySlider(_ time: CMTime, result: Bool) {
        if result {
            let btnSwitch = self.btnReading!.customView! as! UISwitch
            
            if btnSwitch.isOn {
                let index = currentIndex(time)
                
                if let subtitle = subtitles.get(index), let timeRange = subtitle.timeRange {
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
        playerView.seekToTime(time, completionHandler: { (result) in
            if result {
                self.playerView.play()
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        playerView.pause()
        saveStudyLog()
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
            
            if let time = playerView.currentTime() {
                self.currentIndex = currentIndex(time)
                
                if let subtitle = subtitles.get(currentIndex), let timeRange = subtitle.timeRange {
                    playerView.playRange = timeRange
                }
            }
        } else {
            self.sessionControlView.alpha = 0.0
            playerView.playRange = nil
        }
    }
    
    private func playAtIndex(_ index: Int) {
        if let subtitle = subtitles.get(index), let timeRange = subtitle.timeRange {
            playerView.playInTimeRange(timeRange, completion: { (result) in
                self.currentIndex = index
            })
        }
    }
    
    private func currentIndex(_ time: CMTime) -> Int {
        return SubtitleService.shared.currentIndex(time, items: self.subtitles, rangeBlock: { (sub) -> CMTimeRange? in
            return sub.timeRange
        })
    }
    
    private func changeSubtitle(_ time: CMTime) {
        let index = currentIndex(time)
        
        if let subtitle = subtitles.get(index) {
            self.englishSubLabel.text = subtitle.english
            self.koreanSubLabel.text = subtitle.korean
            
            if useAutoScroll {
                if let didSelected = selectedCell {
                    didSelected.englishLabel.textColor = UIColor.black
                    didSelected.koreanLabel.textColor = UIColor.black
                }
                
                let indexPath = IndexPath(row: index, section: 0)
                
                if let willSelected = self.subtitleTableView.cellForRow(at: indexPath) as? SubtitleCell {
                    self.selectedCell = willSelected
                    willSelected.englishLabel.textColor = SubtitlePointColor
                    willSelected.koreanLabel.textColor = UIColor.white
                }
                
                self.subtitleTableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            }
        }
        
        checkSubtitleNavigationButtons(
            index,
            length: subtitles.count,
            prevButton: sessionControlView.prevButton,
            nextButton: sessionControlView.nextButton
        )
    }
    
    func checkSubtitleNavigationButtons(_ index: Int, length: Int, prevButton: UIButton, nextButton: UIButton) {
        setButtonState(prevButton, enable: index != 0)
        setButtonState(nextButton, enable: index != (length - 1))
    }
    
    private func setButtonState(_ button: UIButton, enable: Bool) {
        button.isUserInteractionEnabled = enable
//        button.backgroundColor = enable ? UIColor.clear : RGBA(237, g: 237, b: 237, a: 0.5)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subtitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subtitle = self.subtitles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath) as! SubtitleCell
        cell.update(subtitle)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subtitle = self.subtitles[indexPath.row]
        
        if let time = subtitle.timeRange {
            playerView.seekToTime(time.start)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        useAutoScroll = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { (_) in
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
        
        NotificationCenter.default.post(name: Global.kToggleKoreanLabelVisible, object: nil, userInfo: ["value": isActiveKorean])
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
        
        NotificationCenter.default.post(name: Global.kToggleEnglishLabelVisible, object: nil, userInfo: ["value": isActiveEnglish])
    }
}
  
