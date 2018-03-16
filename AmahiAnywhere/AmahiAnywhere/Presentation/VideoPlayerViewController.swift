//
//  VideoPlayerViewController.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/25/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerViewController: UIViewController {
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    @IBOutlet weak var fastReverseButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var videoControlsStackView: UIStackView!
    @IBOutlet weak var doneButton: UIButton!

    
    // Set the media url from the presenting Viewcontroller
    private var idleTimer: Timer?
    private var mediaPlayer: VLCMediaPlayer?
    public var mediaURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        for view in rootView.subviews {
            let gesture = UITapGestureRecognizer(target: self, action:  #selector(userTouchScreen))
            gesture.delegate = self
            gesture.cancelsTouchesInView = false
            view.addGestureRecognizer(gesture)
        }
        
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
        self.resetScreenIdleTimer()
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
    
    override var next: UIResponder? {
        self.resetScreenIdleTimer()
        return super.next
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
        
        self.resetScreenIdleTimer()
    }
    
}

// Mark - VLC Media Player Delegates
extension VideoPlayerViewController: VLCMediaPlayerDelegate {
    
    @IBAction func rewind(_ sender: Any) {
        self.resetScreenIdleTimer()
        mediaPlayer?.rewind()
    }
    
    @IBAction func forward(_ sender: Any) {
        self.resetScreenIdleTimer()
        mediaPlayer?.fastForward()
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
        self.resetScreenIdleTimer()
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        
        timeLabel.text = mediaPlayer?.time.stringValue
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        
        if mediaPlayer?.state == VLCMediaPlayerState.ended ||
            mediaPlayer?.state == VLCMediaPlayerState.stopped ||
            mediaPlayer?.state == VLCMediaPlayerState.ended  {
            self.keepScreenOn(enabled: false)
            self.perform(#selector(userClickDone(_:)), with: nil, afterDelay: 2.0)
            self.userClickDone(self)
        }
        
        playButton.setImage((mediaPlayer?.isPlaying)! ? UIImage(named:"ic_pause_white"):
            UIImage(named:"ic_play_white"), for: .normal)
    }
}

extension VideoPlayerViewController : UIGestureRecognizerDelegate {
    
}
