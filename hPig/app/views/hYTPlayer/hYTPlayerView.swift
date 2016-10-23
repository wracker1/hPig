//
//  hYTPlayerView.swift
//  hYTPlayer
//
//  Created by Jesse on 2016. 10. 17..
//  Copyright © 2016년 speaking tube. All rights reserved.
//

import UIKit
import AVFoundation

class hYTPlayerView: YTPlayerView, YTPlayerViewDelegate {
    
    private var completion: ((YTPlayerError?) -> Void)? = nil
    private var ignoreRange = false
    private var id: String? = nil
    
    var ticker: ((CMTime) -> Void)? = nil
    var playRange: CMTimeRange? = nil
    
    let currentTimeScale: CMTimeScale = 600

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.black
        self.webView?.allowsInlineMediaPlayback = true
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
    
    func prepareToPlay(_ id: String, range: CMTimeRange, completion: ((YTPlayerError?) -> Void)?) {
        let playerVars: [String: Any] = [
            "controls": 2
            , "playsinline": 1
            , "autohide": 1
            , "showinfo": 0
            , "modestbranding": 0
            , "autoplay": 1
            , "rel": 0
            , "theme": "light"
            , "cc_load_policy": 0
            , "origin" : "https://www.example.com"
        ]
        
        self.id = id
        self.completion = completion
        
        loadVideo(byId: id, startSeconds: timeToFloat(time: range.start), endSeconds: timeToFloat(time: range.end), suggestedQuality: YTPlaybackQuality.medium)
        
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
    
    func currentCMTime() -> CMTime {
        return floatToCMTime(seconds: self.currentTime())
    }
    
    func timeDuration() -> CMTime {
        return CMTimeMakeWithSeconds(Float64(duration()), 600)
    }
    
    /**
     * Invoked when the player view is ready to receive API calls.
     *
     * @param playerView The YTPlayerView instance that has become ready.
     */
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        if let callback = completion {
            callback(nil)
        }
    }
    
    
    /**
     * Callback invoked when player state has changed, e.g. stopped or started playback.
     *
     * @param playerView The YTPlayerView instance where playback state has changed.
     * @param state YTPlayerState designating the new playback state.
     */
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
//        kYTPlayerStateUnstarted,
//        kYTPlayerStateEnded,
//        kYTPlayerStatePlaying,
//        kYTPlayerStatePaused,
//        kYTPlayerStateBuffering,
//        kYTPlayerStateQueued,
//        kYTPlayerStateUnknown
        print("\(state.rawValue)")
    }
    
    
    /**
     * Callback invoked when playback quality has changed.
     *
     * @param playerView The YTPlayerView instance where playback quality has changed.
     * @param quality YTPlaybackQuality designating the new playback quality.
     */
    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality) {
    
    }
    
    
    /**
     * Callback invoked when an error has occured.
     *
     * @param playerView The YTPlayerView instance where the error has occurred.
     * @param error YTPlayerError containing the error state.
     */
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        if let callback = completion {
            callback(error)
        }
    }
    
    
    /**
     * Callback invoked frequently when playBack is plaing.
     *
     * @param playerView The YTPlayerView instance where the error has occurred.
     * @param playTime float containing curretn playback time.
     */
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        let time = floatToCMTime(seconds: playTime)
        
        if let timeRange = playRange {
            if !ignoreRange && !timeRange.containsTime(time) {
                self.pauseVideo()
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
     * @param playerView The YTPlayerView instance where the error has occurred.
     * @return A view object that will be displayed while YouTube iframe API is being loaded.
     *         Pass nil to display no custom loading view. Default implementation returns nil.
     */
    func playerViewPreferredInitialLoading(_ playerView: YTPlayerView) -> UIView? {
        return nil
    }
    
    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
        return UIColor.black
    }
}
