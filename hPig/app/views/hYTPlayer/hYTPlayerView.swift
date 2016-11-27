//
//  hYTPlayerView.swift
//  hYTPlayer
//
//  Created by Jesse on 2016. 10. 17..
//  Copyright © 2016년 speaking tube. All rights reserved.
//

import UIKit
import AVFoundation

class hYTPlayerView: WKYTPlayerView, WKYTPlayerViewDelegate {
    
    private var completion: ((WKYTPlayerError?) -> Void)? = nil
    private var ignoreRange = false
    private var id: String? = nil
    
    //        https://developers.google.com/youtube/player_parameters?playerVersion=HTML5
    
    var playerVars: [String: Any] = [
        "controls": 0
        , "playsinline": 1
        , "autohide": 1
        , "showinfo": 0
        , "modestbranding": 1
        , "autoplay": 1
        , "rel": 0
        , "fs": 0
        , "theme": "light"
        , "cc_load_policy": 0
        , "iv_load_policy": 3
        , "enablejsapi" : 0
        , "origin" : "https://www.example.com"
    ]
    
    var ticker: ((CMTime, Bool) -> Void)? = nil
    var pauseHook: ((CMTime) -> Void)? = nil
    var playRange: CMTimeRange? = nil
    
    let currentTimeScale: CMTimeScale = 600

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.black
//        self.webView?.allowsInlineMediaPlayback = true
        self.delegate = self
    }
    
    deinit {
        self.stopVideo()
    }
    
    private func floatToCMTime(seconds: Float) -> CMTime {
        return CMTimeMakeWithSeconds(Float64(seconds), 600)
    }
    
    private func timeToFloat(time: CMTime) -> Float {
        return Float(CMTimeGetSeconds(time))
    }
    
    func prepareToPlay(_ id: String, range: CMTimeRange, completion: ((WKYTPlayerError?) -> Void)?) {
        self.id = id
        self.completion = completion
        
//        let start = timeToFloat(time: range.start)
//        let end = timeToFloat(time: range.end)
//        
//        load(withPlayerParams: playerVars)
//        
//        loadVideo(byId: id, startSeconds: start, endSeconds: end, suggestedQuality: .small)
        
        load(withVideoId: id, playerVars: playerVars)
    }

    func playInTimeRange(_ timeRange: CMTimeRange, completion: (() -> Void)?) {
        self.seek(toSeconds: timeToFloat(time: timeRange.start), allowSeekAhead: true)
        
        self.ignoreRange = true
        self.playRange = timeRange
        self.playVideo()
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            self.ignoreRange = false
        }
        
        if let callback = completion {
            callback()
        }
    }
    
    func seek(toTime: CMTime) {
        self.seek(toSeconds: timeToFloat(time: toTime), allowSeekAhead: true)
    }
    
    func currentCMTime(completion: ((CMTime) -> Void)?) {
        if let callback = completion {
            self.getCurrentTime({ (seconds, error) in
                callback(self.floatToCMTime(seconds: seconds))
            })
        }
    }
    
    func timeDuration(completion: ((CMTime) -> Void)?) {
        if let callback = completion {
            self.getDuration({ (dur, error) in
                callback(CMTimeMakeWithSeconds(Float64(dur), 600))
            })
        }
    }
    
    // wk yt player
    
    /**
     * Invoked when the player view is ready to receive API calls.
     *
     * @param playerView The WKYTPlayerView instance that has become ready.
     */
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        if let callback = completion {
            callback(nil)
        }
    }
    
    /**
     * Callback invoked when player state has changed, e.g. stopped or started playback.
     *
     * @param playerView The WKYTPlayerView instance where playback state has changed.
     * @param state WKYTPlayerState designating the new playback state.
     */
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        switch state {
        case .unstarted:
            print("player state: unstarted")
            
        case .ended:
            print("player state: ended")
            
            currentCMTime(completion: { (time) in
                if let action = self.ticker {
                    action(time, false)
                }
            })
            
        case .playing:
            print("player state: playing")
            
        case .paused:
            print("player state: paused")
            
        case .buffering:
            print("player state: buffering")
            
        case .queued:
            print("player state: queued")
            
        case .unknown:
            print("player state: unknown")
        }
    }
    
    /**
     * Callback invoked when playback quality has changed.
     *
     * @param playerView The WKYTPlayerView instance where playback quality has changed.
     * @param quality WKYTPlaybackQuality designating the new playback quality.
     */
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo quality: WKYTPlaybackQuality) {
        
    }
    
    /**
     * Callback invoked when an error has occured.
     *
     * @param playerView The WKYTPlayerView instance where the error has occurred.
     * @param error WKYTPlayerError containing the error state.
     */
    
    func playerView(_ playerView: WKYTPlayerView, receivedError error: WKYTPlayerError) {
        if let callback = completion {
            callback(error)
        }
    }
    
    /**
     * Callback invoked frequently when playBack is plaing.
     *
     * @param playerView The WKYTPlayerView instance where the error has occurred.
     * @param playTime float containing curretn playback time.
     */
    
    func playerView(_ playerView: WKYTPlayerView, didPlayTime playTime: Float) {
        let time = floatToCMTime(seconds: playTime)
        
        if let timeRange = playRange {
            if !ignoreRange && !timeRange.containsTime(time) {
                self.pauseVideo()
                
                if let hook = pauseHook {
                    hook(time)
                }
            } else {
                if let action = ticker {
                    action(time, true)
                }
            }
        } else {
            if let action = ticker {
                action(time, true)
            }
        }
    }
    
    /**
     * Callback invoked when setting up the webview to allow custom colours so it fits in
     * with app color schemes. If a transparent view is required specify clearColor and
     * the code will handle the opacity etc.
     *
     * @param playerView The WKYTPlayerView instance where the error has occurred.
     * @return A color object that represents the background color of the webview.
     */
    
    func playerViewPreferredWebViewBackgroundColor(_ playerView: WKYTPlayerView) -> UIColor {
        return UIColor.black
    }
    
    /**
     * Callback invoked when initially loading the YouTube iframe to the webview to display a custom
     * loading view while the player view is not ready. This loading view will be dismissed just before
     * -playerViewDidBecomeReady: callback is invoked. The loading view will be automatically resized
     * to cover the entire player view.
     *
     * The default implementation does not display any custom loading views so the player will display
     * a blank view with a background color of (-playerViewPreferredWebViewBackgroundColor:).
     *
     * Note that the custom loading view WILL NOT be displayed after iframe is loaded. It will be
     * handled by YouTube iframe API. This callback is just intended to tell users the view is actually
     * doing something while iframe is being loaded, which will take some time if users are in poor networks.
     *
     * @param playerView The WKYTPlayerView instance where the error has occurred.
     * @return A view object that will be displayed while YouTube iframe API is being loaded.
     *         Pass nil to display no custom loading view. Default implementation returns nil.
     */
    
    func playerViewPreferredInitialLoading(_ playerView: WKYTPlayerView) -> UIView? {
        return nil
    }

}
