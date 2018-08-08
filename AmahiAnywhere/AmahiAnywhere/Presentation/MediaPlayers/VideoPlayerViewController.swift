//
//  VideoPlayerViewController.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/25/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore

class VideoPlayerViewController: UIViewController {
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var videoControlsView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var rewindIndicator: UIImageView!
    @IBOutlet weak var forwardIndicator: UIImageView!
    @IBOutlet weak var timeSlider: UISlider!
    
    // Set the media url from the presenting Viewcontroller
    private var idleTimer: Timer?
    private var mediaPlayer: VLCMediaPlayer?
    public var mediaURL: URL!
    
    private var hasMediaFileParseFinished = false
    private var hasPlayStarted = false
    
    fileprivate static let IntervalForFastRewindAndFastForward: Int32 = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scrobbleTapGesture = UITapGestureRecognizer(target: self, action:  #selector(userTapScrobblePosition(_:)))
        timeSlider.addGestureRecognizer(scrobbleTapGesture)
        
        timeSlider.setThumbImage(UIImage(named: "sliderKnobIcon"), for: .normal)
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(userTouchScreen))
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        movieView.addGestureRecognizer(gesture)

        listenForNotifications()
        self.setUpIndicatorLayers(imageView: rewindIndicator)
        self.setUpIndicatorLayers(imageView: forwardIndicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mediaPlayer = VLCMediaPlayer()
        mediaPlayer?.delegate = self
        mediaPlayer?.drawable = self.movieView
        mediaPlayer?.media = VLCMedia(url: mediaURL)
        
        // Play media file immediately after video player launches
        mediaPlayer?.play()
        
        durationLabel.text = mediaPlayer?.media.length.stringValue
        
        if self.videoControlsView.isHidden {
            self.videoControlsView.isHidden = false
        }
        videoControlsView.superview?.bringSubview(toFront: videoControlsView)
        self.keepScreenOn(enabled: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let _ = mediaPlayer?.isPlaying {
            mediaPlayer?.pause()
        }
        
        if idleTimer != nil {
            idleTimer?.invalidate()
            idleTimer = nil
        }
        self.keepScreenOn(enabled: false)
    }
    
    func listenForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)),
                                               name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
    }
    
    @objc func handleRouteChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let reasonRaw = userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber,
            let reason = AVAudioSessionRouteChangeReason(rawValue: reasonRaw.uintValue)
            else { fatalError("Strange... could not get routeChange") }
        if reason == .oldDeviceUnavailable {
            DispatchQueue.main.async(execute: {
                self.mediaPlayer?.pause()
                self.userTouchScreen()   // Handle this event as if it is user-touch triggered
            })
        }
    }
    
    func setUpIndicatorLayers(imageView: UIImageView) {
        
        imageView.layer.shadowColor = UIColor.softYellow.cgColor
        
        let image = imageView.image
        let templateImage = image?.withRenderingMode(.alwaysTemplate)
        imageView.image = templateImage
        imageView.tintColor = UIColor.softYellow
        
        imageView.layer.shadowRadius = 5.0
        imageView.layer.shadowOpacity = 0.8
        imageView.layer.masksToBounds = false
        imageView.layer.shouldRasterize = true
        
        imageView.alpha = 0.0 // Hide indicator when player opens
    }
    
    func keepScreenOn(enabled: Bool) {
        UIApplication.shared.isIdleTimerDisabled = enabled
    }
    
    func resetScreenIdleTimer() {
        
        if idleTimer == nil {
            
            idleTimer = Timer.scheduledTimer(timeInterval: 3.0,
                                             target: self,
                                             selector: #selector(idleTimeExceded),
                                             userInfo: nil,
                                             repeats: false)
        } else {
            if fabs((idleTimer?.fireDate.timeIntervalSinceNow)!) < 3.0 {
                idleTimer?.fireDate = Date.init(timeIntervalSinceNow: 3.0)
            }
        }
    }
    
    @objc func idleTimeExceded() {
        
        idleTimer = nil
        
        if !videoControlsView.isHidden {
            videoControlsView.alpha = 1.0
            doneButton.alpha = 1.0
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [],
                           animations: {
                self.videoControlsView.alpha = 0.0
                self.doneButton.alpha = 0.0
            }) { (completed) in
                self.videoControlsView.isHidden = true
                self.doneButton.isHidden = true
            }
        }
    }
    
    @objc func userTouchScreen() {
                
        if !videoControlsView.isHidden {
            videoControlsView.isHidden = true
            doneButton.isHidden = true
            videoControlsView.alpha = 0
            doneButton.alpha = 0
            return
        }
        
        videoControlsView.layer.removeAllAnimations()
        doneButton.layer.removeAllAnimations()
        
        videoControlsView.isHidden = false
        doneButton.isHidden = false
        videoControlsView.alpha = 1.0
        doneButton.alpha = 1.0
        
        resetTimeAfterStateChanged()
    }
    
    @objc func resetTimeAfterStateChanged() {
        
        if mediaPlayer!.isPlaying {
            self.resetScreenIdleTimer()
        }
    }
    
    @IBAction func rewind(_ sender: Any) {
        mediaPlayer?.jumpBackward(VideoPlayerViewController.IntervalForFastRewindAndFastForward)
        self.showIndicator(imageView: rewindIndicator)
    }
    
    @IBAction func forward(_ sender: Any) {
        mediaPlayer?.jumpForward(VideoPlayerViewController.IntervalForFastRewindAndFastForward)
        self.showIndicator(imageView: forwardIndicator)
    }
    
    func showIndicator(imageView: UIImageView) {
        
        imageView.layer.removeAllAnimations()
        imageView.alpha = 1.0
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [],
                       animations: {
                        imageView.alpha = 0.0
        }, completion: nil)
    }
    
    @IBAction func userClickDone(_ sender: Any) {
        mediaPlayer?.stop()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playandPause(_ sender: Any) {
        if (mediaPlayer?.isPlaying)! {
            mediaPlayer?.pause()
            idleTimer?.invalidate()
            idleTimer = nil
        } else {
            mediaPlayer?.play()
        }
    }
    
    @IBAction func userChangedMediaPosition(_ sender: UISlider) {
        
        if hasMediaFileParseFinished {
            let newPosition = VLCTime.init(number: sender.value as NSNumber)
            mediaPlayer?.position = (newPosition?.value.floatValue)! / (mediaPlayer?.media.length.value.floatValue)!
            timeElapsedLabel.text = newPosition?.stringValue
            durationLabel.text = mediaPlayer?.media.length.stringValue
        } else {
            timeSlider.value = 0.0
        }
        
        self.resetScreenIdleTimer()
    }
    
    @objc func userTapScrobblePosition(_ tapGesture: UITapGestureRecognizer) {
        
        if timeSlider.isHighlighted {
            return
        }
        let point = tapGesture.location(in: timeSlider)
        let percentage = point.x / timeSlider.bounds.size.width
        let delta = Float(percentage) * (timeSlider.maximumValue - timeSlider.minimumValue)
        let value = timeSlider.minimumValue + delta

        timeSlider.setValue(value, animated: true)
        
        if !(mediaPlayer?.isPlaying)! {
            mediaPlayer?.play()
        }
        
        self.userChangedMediaPosition(timeSlider)
    }
    
    @IBAction func scrobblePositionTouchDown(_ sender: Any) {
        self.idleTimer?.invalidate()
        self.idleTimer = nil
    }
}

// Mark - VLC Media Player Delegates
extension VideoPlayerViewController: VLCMediaPlayerDelegate {
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        timeSlider.value = Float(truncating: (mediaPlayer?.time.value)!)
        timeElapsedLabel.text = mediaPlayer?.time.stringValue
        durationLabel.text = mediaPlayer?.media.length.stringValue

        if !hasPlayStarted {
            hasPlayStarted = true
            self.resetScreenIdleTimer()
        }
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        debugPrint("Player State \(VLCMediaPlayerStateToString((mediaPlayer?.state)!))")
        
        if mediaPlayer?.state == VLCMediaPlayerState.ended ||
            mediaPlayer?.state == VLCMediaPlayerState.stopped {
            self.keepScreenOn(enabled: false)
            self.dismiss(animated: true, completion: nil)
        } else if mediaPlayer?.state == VLCMediaPlayerState.buffering ||
            mediaPlayer?.state == VLCMediaPlayerState.paused {
            
            if !hasMediaFileParseFinished && (mediaPlayer?.media.length.intValue != 0) {
                
                timeSlider.maximumValue = Float(truncating: (mediaPlayer?.media.length.value)!)
                hasMediaFileParseFinished = true
            }
            self.videoControlsView.isHidden = false
        } else if mediaPlayer?.state == VLCMediaPlayerState.playing {
            self.resetScreenIdleTimer()
        } else {
            self.videoControlsView.isHidden = false
            idleTimer?.invalidate()
            idleTimer = nil
        }
        
        playButton.setImage((mediaPlayer?.isPlaying)! ? UIImage(named:"pauseIcon"):
            UIImage(named:"playIcon"), for: .normal)
    }
}

extension VideoPlayerViewController : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}
