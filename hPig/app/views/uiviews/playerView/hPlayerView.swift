//
//  hPlayerView.swift
//  hPig
//
//  Created by Jesse on 2016. 9. 22..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class hPlayerView: UIView {

    @IBOutlet var controlView: UIView!
    
    private var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
    
    var playRange: CMTimeRange? = nil
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    private let loadingIndicator: UIActivityIndicatorView
    private var ignoreRange = false
    
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    private var isPlaying = false
    private var timer: Timer? = nil
    private var duration: CMTime? = nil
    
    var ticker: ((CMTime) -> Void)? = nil
    var seekBySlider: ((CMTime, Bool) -> Void)? = nil
    
    required init?(coder aDecoder: NSCoder) {
        self.loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(coder: aDecoder)
        
        LayoutService.shared.layoutXibViews(superview: self, nibName: "st_player_view") { (view) in
            self.controlView = view
        }
        
        self.addSubview(loadingIndicator)
        let centerX = NSLayoutConstraint(item: loadingIndicator, attribute: .centerX, relatedBy: .equal, toItem: loadingIndicator.superview, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let centerY = NSLayoutConstraint(item: loadingIndicator, attribute: .centerY, relatedBy: .equal, toItem: loadingIndicator.superview, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        self.addConstraint(centerX)
        self.addConstraint(centerY)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        toggleController()
    }
    
    deinit {
        stop()
        
        self.ticker = nil
    }
    
    func currentItem() -> AVPlayerItem? {
        return self.player?.currentItem
    }
    
    func currentItemTimeScale() -> CMTimeScale? {
        return self.currentItem()?.asset.duration.timescale
    }
    
    func prepareToPlay(_ id: String, completion: @escaping (Error?) -> Void) throws {
        YoutubeService.shared.videoInfo(id: id, completion: { (data, error) in
            if let item = data.last  {
                DispatchQueue.global().async {
                    let url = item.url
                    let player = AVPlayer(url: URL(string: url)!)
                    
                    print("VIDEO DATA: \(data)\n")
                    print("STREAM VIDEO: \(item)")
                    
                    self.player = player
                    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    self.player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
                    
                    if let currentItem = self.player!.currentItem {
                        let duration = currentItem.asset.duration
                        self.duration = duration
                        
                        var status: AVPlayerItemStatus = .unknown
                        
                        repeat {
                            status = currentItem.status
                        } while status != .readyToPlay
                        
                        DispatchQueue.main.async {
                            self.timeSlider.maximumValue = Float(TimeFormatService.shared.secondsFromCMTime(time: duration))
                            self.timeSlider.isUserInteractionEnabled = true
                            self.durationLabel.text = TimeFormatService.shared.timeStringFromCMTime(time: duration)
                            
                            completion(nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(NSError(domain: "", code: 400, userInfo: ["message": "\(id) empty duration info."]))
                        }
                    }
                }
            } else {
                completion(NSError(domain: "", code: 400, userInfo: ["message": "\(id) empty video data."]))
            }
        })
    }
    
    @IBAction func seekFromTimeSlider(_ sender: AnyObject) {
        self.pause()
        
        let time = TimeFormatService.shared.timeFromFloat(seconds: timeSlider.value)
        
        seekToTime(time, completionHandler: { (result) in
            if let action = self.seekBySlider {
                action(time, result)
            }
            
            if result {
                self.play()
            }
        })
    }
    
    func currentTime() -> CMTime? {
        return self.player?.currentTime()
    }
    
    func seekToTime(_ time: CMTime) {
        self.seekToTime(time) { (result) in
            
        }
    }
    
    func seekToTime(_ time: CMTime, completionHandler: @escaping (Bool) -> Void) {
        startLoadingIndicator()
        
        self.player?.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: completionHandler)
    }
    
    func playInTimeRange(_ timeRange: CMTimeRange, completion: @escaping (Bool) -> Void) {
        seekToTime(timeRange.start) { (result) in
            if result {
                self.ignoreRange = true
                self.playRange = timeRange
                self.play()
                
                Timer.scheduledTimer(
                    timeInterval: 0.5,
                    target: self,
                    selector: #selector(self.deactiveIgnoreRange),
                    userInfo: nil,
                    repeats: false
                )
            }
            
            completion(result)
        }
    }
    
    func deactiveIgnoreRange() {
        self.ignoreRange = false
    }
    
    func pause() {
        if isPlaying {
            player?.pause()
            stop()
            isPlaying = false
            playButton.setImage(#imageLiteral(resourceName: "btn_play"), for: .normal)
        }
    }
    
    func play() {
        if !isPlaying {
            start()
            player?.play()
            isPlaying = true
            playButton.setImage(#imageLiteral(resourceName: "btn_pause"), for: .normal)
            
            if controlView.alpha == 1.0 {
                Timer.scheduledTimer(
                    timeInterval: 0.5,
                    target: self,
                    selector: #selector(self.hideController),
                    userInfo: nil,
                    repeats: false
                )
            }
        }
    }
    
    @IBAction func togglePlay() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    @IBAction func prev() {
        let start = CMTimeMakeWithSeconds(0.0, 600)
        
        pause()
        
        seekToTime(start) { (result) in
            if result {
                self.play()
            } else {
                self.pause()
            }
        }
    }
    
    @IBAction func next() {
        let end = self.duration ?? CMTimeMakeWithSeconds(0.0, 600)
        
        pause()
        
        seekToTime(end) { (result) in
            if result {
                self.play()
            } else {
                self.pause()
            }
        }
    }
    
    func tick() {
        if let p = player {
            let time = p.currentTime()
            
            if let loadedRange = p.currentItem?.loadedTimeRanges {
                checkLoadingIndicator(loadedRanges: loadedRange, current: time)
            }
            
            timeSlider.value = TimeFormatService.shared.secondsFromCMTime(time: time)
            currentLabel.text = TimeFormatService.shared.timeStringFromCMTime(time: time)
            
            if let timeRange = playRange {
                if !ignoreRange && !timeRange.containsTime(time) {
                    //                    print("current: \(time.seconds), range: \(timeRange.start.seconds), \(timeRange.end.seconds)")
                    
                    self.pause()
                } else {
                    if let action = ticker {
                        action(time)
                    }
                }
            } else {
                if let action = ticker {
                    action(time)
                }
            }
        }
    }
    
    private func checkLoadingIndicator(loadedRanges: [NSValue], current: CMTime) {
        let data = loadedRanges.map({ (value) -> CMTimeRange in
            return value.timeRangeValue
        })
        
        if let range = data.get(0), let duration = currentItem()?.duration {
            let isTimeInRange = current < duration
            
            if isTimeInRange && !range.containsTime(current) && !loadingIndicator.isAnimating {
                startLoadingIndicator()
            } else if loadingIndicator.isAnimating {
                stopLoadingIndicator()
            }
        }
    }
    
    func toggleController() {
        if self.controlView.alpha < 1.0 {
            showController()
        } else {
            hideController()
        }
    }
    
    func showController() {
        UIView.animate(withDuration: 0.3) { 
            self.controlView.alpha = 1.0
        }
    }
    
    func hideController() {
        UIView.animate(withDuration: 0.3) {
            self.controlView.alpha = 0.0
        }
    }
    
    func startLoadingIndicator() {
        loadingIndicator.startAnimating()
    }
    
    func stopLoadingIndicator() {
        loadingIndicator.stopAnimating()
    }
    
    private func start() {
        self.timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(self.tick),
            userInfo: nil,
            repeats: true
        )
    }
    
    private func stop() {
        if let timer = self.timer {
            timer.invalidate()
            
            self.timer = nil
        }
    }

}
