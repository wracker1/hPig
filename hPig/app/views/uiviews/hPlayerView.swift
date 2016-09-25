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
        
        XibService.shared.layoutXibViews(superview: self, nibName: "st_player_view") { (view) in
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
    
    func prepareToPlay(_ id: String, completion: @escaping (Error?) -> Void) {
        
        DispatchQueue.global().async {
            YoutubeService.shared.videoInfo(id: id, completion: { (data, error) in
                if data.count > 0 {
                    let url = data[0].url
                    
                    self.player = AVPlayer(url: URL(string: url)!)
                    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    self.player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
                    
                    if let duration = self.player!.currentItem?.asset.duration {
                        self.duration = duration
                        
                        DispatchQueue.main.async {
                            self.timeSlider.maximumValue = Float(TimeFormatService.shared.secondsFromCMTime(time: duration))
                            self.timeSlider.isUserInteractionEnabled = true
                            self.durationLabel.text = TimeFormatService.shared.timeStringFromCMTime(time: duration)
                        }
                        
                        completion(nil)
                    } else {
                        completion(NSError(domain: "", code: 400, userInfo: ["message": "\(id) empty duration info."]))
                    }
                } else {
                    completion(NSError(domain: "", code: 400, userInfo: ["message": "\(id) empty video data."]))
                }
            })
        }
    }
    
    @IBAction func seekFromTimeSlider(sender: AnyObject) {
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
        
        //        2016-08-29 22:29:45.150 speaking-tube[1013:414061] *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'AVPlayerItem cannot service a seek request with a completion handler until its status is AVPlayerItemStatusReadyToPlay.'
        //        *** First throw call stack:
        //        (0x1816cedb0 0x180d33f80 0x187da3720 0x187d8fe48 0x1000573d0 0x10005763c 0x1000446e0 0x100046984 0x100063b74 0x1000686c8 0x1003716d4 0x1001b099c 0x10016ed08 0x100aa1a7c 0x100aa1a3c 0x100aa74e4 0x181684d50 0x181682bb8 0x1815acc50 0x182e94088 0x18689a088 0x10006b9b4 0x18114a8b8)
        //        libc++abi.dylib: terminating with uncaught exception of type NSException
        //
        
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
            playButton.setImage(UIImage(named: "btn_play"), for: .normal)
        }
    }
    
    func play() {
        if !isPlaying {
            start()
            player?.play()
            isPlaying = true
            playButton.setImage(UIImage(named: "btn_pause"), for: .normal)
            
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
        
        if let range = data.get(0) {
            
            if !range.containsTime(current) && !loadingIndicator.isAnimating {
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
