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
    
    private var doubleTapGesture: UITapGestureRecognizer!
    private var tapGesture: UITapGestureRecognizer!

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
        
        let videoControlsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resetScreenIdleTimer))
        videoControlsTapGestureRecognizer.cancelsTouchesInView = false
        videoControlsView.isUserInteractionEnabled = true
        videoControlsView.addGestureRecognizer(videoControlsTapGestureRecognizer)
        
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapRecognized(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self
        
        tapGesture = UITapGestureRecognizer(target: self, action:  #selector(userTouchScreen))
        tapGesture.delegate = self
        movieView.isUserInteractionEnabled = true
 
        movieView.addGestureRecognizer(doubleTapGesture)
        movieView.addGestureRecognizer(tapGesture)

        listenForNotifications()
        setUpIndicatorLayers(imageView: rewindIndicator)
        setUpIndicatorLayers(imageView: forwardIndicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mediaPlayer = VLCMediaPlayer()
        mediaPlayer?.delegate = self
        mediaPlayer?.drawable = movieView
        mediaPlayer?.media = VLCMedia(url: mediaURL)
        
        // Play media file immediately after video player launches
        mediaPlayer?.play()
        
        durationLabel.text = mediaPlayer?.media.length.stringValue
        
        if videoControlsView.isHidden {
            videoControlsView.isHidden = false
        }
        videoControlsView.superview?.bringSubviewToFront(videoControlsView)
        keepScreenOn(enabled: true)
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
        keepScreenOn(enabled: false)
    }
    
    func listenForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)),
                                               name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    @objc func handleRouteChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let reasonRaw = userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonRaw.uintValue)
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
    
    @objc func resetScreenIdleTimer() {
        AmahiLogger.log("resetScreenIdleTimer was called")

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
        AmahiLogger.log("idleTimeExceded was called")
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
    
    @objc func doubleTapRecognized(_ recognizer: UITapGestureRecognizer?) {
        
        let touchPoint = recognizer?.location(in: movieView)
        
        let isRight =  touchPoint!.x > movieView.center.x
        if isRight {
            forward(nil)
        } else {
            rewind(nil)
        }
        
    }
    
    @objc func userTouchScreen() {
        AmahiLogger.log("userTouchScreen was called")

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
        AmahiLogger.log("resetTimeAfterStateChanged was called")
        if mediaPlayer!.isPlaying {
            resetScreenIdleTimer()
        }
    }
    
    @IBAction func rewind(_ sender: Any?) {
        mediaPlayer?.jumpBackward(VideoPlayerViewController.IntervalForFastRewindAndFastForward)
        showIndicator(imageView: rewindIndicator)
        if sender != nil {
            resetTimeAfterStateChanged()
            
        }
    }
    
    @IBAction func forward(_ sender: Any?) {
        mediaPlayer?.jumpForward(VideoPlayerViewController.IntervalForFastRewindAndFastForward)
        showIndicator(imageView: forwardIndicator)
        if sender != nil {
            resetTimeAfterStateChanged()
            
        }    }
    
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
        dismiss(animated: true, completion: nil)
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
        
        resetScreenIdleTimer()
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
        
        userChangedMediaPosition(timeSlider)
    }
    
    @IBAction func scrobblePositionTouchDown(_ sender: Any) {
        idleTimer?.invalidate()
        idleTimer = nil
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
            resetScreenIdleTimer()
        }
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        AmahiLogger.log("Player State \(VLCMediaPlayerStateToString((mediaPlayer?.state)!))")
        
        if mediaPlayer?.state == VLCMediaPlayerState.ended ||
            mediaPlayer?.state == VLCMediaPlayerState.stopped {
            keepScreenOn(enabled: false)
            dismiss(animated: true, completion: nil)
        } else if mediaPlayer?.state == VLCMediaPlayerState.buffering ||
            mediaPlayer?.state == VLCMediaPlayerState.paused {
            
            if !hasMediaFileParseFinished && (mediaPlayer?.media.length.intValue != 0) {
                
                timeSlider.maximumValue = Float(truncating: (mediaPlayer?.media.length.value)!)
                hasMediaFileParseFinished = true
            }
            videoControlsView.isHidden = false
        } else if mediaPlayer?.state == VLCMediaPlayerState.playing {
            resetScreenIdleTimer()
        } else {
            videoControlsView.isHidden = false
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Don't recognize a single tap until a double-tap fails.
        if gestureRecognizer == tapGesture && otherGestureRecognizer == doubleTapGesture {
            return true
        }
        return false
    }
}
