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
    @IBOutlet weak var fastReverseButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var videoControlsStackView: UIStackView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var rewindIndicator: UIImageView!
    @IBOutlet weak var forwardIndicator: UIImageView!
    
    // Set the media url from the presenting Viewcontroller
    private var idleTimer: Timer?
    private var mediaPlayer: VLCMediaPlayer?
    public var mediaURL: URL!
    
    fileprivate let JUMP_INTERVAL: Int32 = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        for view in rootView.subviews {
            let gesture = UITapGestureRecognizer(target: self, action:  #selector(userTouchScreen))
            gesture.delegate = self
            gesture.cancelsTouchesInView = false
            view.addGestureRecognizer(gesture)
        }
        
        self.setUpIndicatorLayers(imageView: rewindIndicator)
        self.setUpIndicatorLayers(imageView: forwardIndicator)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mediaPlayer = VLCMediaPlayer()
        mediaPlayer?.delegate = self
        mediaPlayer?.drawable = self.movieView
        mediaPlayer?.media = VLCMedia(url: mediaURL)
        
        // Play media file immediately after video player launches
        mediaPlayer?.play()
        
        if self.videoControlsStackView.isHidden {
            self.videoControlsStackView.isHidden = false
        }
        videoControlsStackView.superview?.bringSubview(toFront: videoControlsStackView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let _ = mediaPlayer?.media {
            mediaPlayer?.stop()
        }
        
        if idleTimer != nil {
            idleTimer?.invalidate()
            idleTimer = nil
        }
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
        
        if !videoControlsStackView.isHidden {
            videoControlsStackView.alpha = 1.0
            doneButton.alpha = 1.0
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [],
                           animations: {
                            self.videoControlsStackView.alpha = 0.0
                            self.doneButton.alpha = 0.0
            }) { (completed) in
                self.videoControlsStackView.isHidden = true
                self.doneButton.isHidden = true
            }
        }
    }
    
    @objc func userTouchScreen() {
        
        videoControlsStackView.layer.removeAllAnimations()
        doneButton.layer.removeAllAnimations()
        
        videoControlsStackView.isHidden = false
        doneButton.isHidden = false
        videoControlsStackView.alpha = 1.0
        doneButton.alpha = 1.0
        
        self.perform(#selector(resetTimeAfterStateChanged), with: nil, afterDelay: 1.0)
    }
    
    @objc func resetTimeAfterStateChanged() {
        if mediaPlayer!.isPlaying {
            self.resetScreenIdleTimer()
        }
    }
}

// Mark - VLC Media Player Delegates
extension VideoPlayerViewController: VLCMediaPlayerDelegate {
    
    @IBAction func rewind(_ sender: Any) {
        self.resetScreenIdleTimer()
        mediaPlayer?.jumpBackward(JUMP_INTERVAL)
        self.showIndicator(imageView: rewindIndicator)
    }
    
    @IBAction func forward(_ sender: Any) {
        self.resetScreenIdleTimer()
        mediaPlayer?.jumpForward(JUMP_INTERVAL)
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
        } else {
            mediaPlayer?.play()
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        
        timeLabel.text = mediaPlayer?.time.stringValue
        
        if mediaPlayer!.time.stringValue == "00:00" {
            self.resetScreenIdleTimer()
        }
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        debugPrint("Player State \(VLCMediaPlayerStateToString(mediaPlayer!.state))")

        if mediaPlayer?.state == VLCMediaPlayerState.ended ||
            mediaPlayer?.state == VLCMediaPlayerState.stopped {
            self.keepScreenOn(enabled: false)
            self.perform(#selector(userClickDone(_:)), with: nil, afterDelay: 2.0)
        } else if mediaPlayer?.state == VLCMediaPlayerState.buffering ||
            mediaPlayer?.state == VLCMediaPlayerState.paused {
            self.keepScreenOn(enabled: true)
            self.videoControlsStackView.isHidden = false
            idleTimer = nil
        } else if mediaPlayer?.state == VLCMediaPlayerState.playing {
            self.keepScreenOn(enabled: false)
            self.resetScreenIdleTimer()
        } else {
            self.keepScreenOn(enabled: true)
            self.videoControlsStackView.isHidden = false
            idleTimer = nil
        }
        
        playButton.setImage((mediaPlayer?.isPlaying)! ? UIImage(named:"ic_pause_white"):
            UIImage(named:"ic_play_white"), for: .normal)
    }
}

extension VideoPlayerViewController : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}
