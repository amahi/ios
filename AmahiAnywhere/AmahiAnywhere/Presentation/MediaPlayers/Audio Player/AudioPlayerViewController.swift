//
//  MusicPlayerViewController.swift
//  AmahiAnywhere
//
//  Created by Abhishek Sansanwal on 06/06/19.
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

enum QueueState{
    case collapsed
    case open
}

class AudioPlayerViewController: UIViewController {
    
    @IBOutlet weak var playerContainer: UIView!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var musicArtImageView: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    
    lazy var dataModel = AudioPlayerDataModel.shared
    
    var playerQueueContainer : PlayerQueueContainerView!
    
    var queueVCHeight = UIScreen.main.bounds.height * 0.72
    
    var queueTopConstraintForOpen:NSLayoutConstraint?
    var queueTopConstraintForCollapse: NSLayoutConstraint?
    
    public var player: AVPlayer!
    var sliderDragging = false
    var songDuration = 0.0
    var lastSongIndex = 0
    var elapsedTime = 0
    
    var startedPlayer = false
    var offlineMode = false
    
    var observer: Any?
    
    var interactiveAnimators: [UIViewPropertyAnimator] = []
    var animationProgressWhenInterrupted:CGFloat = 0
    
    var currentQueueState:QueueState = .collapsed
    var nextState:QueueState{
        return currentQueueState == QueueState.collapsed ? .open : .collapsed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataModel.currentPlayerItem = dataModel.startPlayerItem
        dataModel.queuedItems.remove(at: 0)
        player = AVPlayer(playerItem: dataModel.startPlayerItem)
        player.automaticallyWaitsToMinimizeStalling = true
        AppUtility.lockOrientation(.portrait)
        timeSlider.setThumbImage(UIImage(named: "sliderKnobIcon"), for: .normal)
        timeSlider.addTarget(self, action: #selector(timeSliderChanged(slider:event:)), for: .valueChanged)
        
        shuffleButton.setImage(UIImage(named:"shuffle"), for: .normal)
        repeatButton.setImage(UIImage(named:"repeat"), for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hadleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadSong), name: .audioPlayerDidSetMetaData, object: nil)
        
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget(self, action: #selector(remotePlayPause))
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(self, action: #selector(remoteNext))
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(self, action: #selector(remotePrevious))
        
        MPRemoteCommandCenter.shared().seekForwardCommand.isEnabled = false
        MPRemoteCommandCenter.shared().seekBackwardCommand.isEnabled = false
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.isEnabled = true
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget(self, action:#selector(remoteChangedPlaybackPositionCommand(_:)))
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        playerQueueContainer = PlayerQueueContainerView(target: self)
        playerQueueContainer.header.arrowHead.addTarget(self, action: #selector(handleArrowHeadTap), for: .touchDown)
        playerQueueContainer.header.tapDelegate = self
        layoutPlayerQueue()

        
        if offlineMode{
            loadSong()
            playPlayer()
            observer = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { [weak self] (time) in
                self?.updatePlayingSong(time)
            })
        }
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.playerContainer.addGestureRecognizer(panRecognizer)
        panRecognizer.cancelsTouchesInView = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !startedPlayer && !offlineMode{
            startedPlayer = true
            loadSong()
            playPlayer()
            observer = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { [weak self] (time) in
                self?.updatePlayingSong(time)
            })
        }
        playerQueueContainer.queueVC.tableView.reloadData()
    }
    
    func cleanupBeforeExit(){
        player.pause()
        if let observer = observer{
            player.removeTimeObserver(observer)
        }
        player = nil
        NotificationCenter.default.removeObserver(self)
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.removeTarget(self)
        MPRemoteCommandCenter.shared().nextTrackCommand.removeTarget(self)
        MPRemoteCommandCenter.shared().previousTrackCommand.removeTarget(self)
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.removeTarget(self)
        timeSlider.removeTarget(self, action: #selector(timeSliderChanged(slider:event:)), for: .valueChanged)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        UIApplication.shared.endReceivingRemoteControlEvents()
        AppUtility.lockOrientation(.all)
    }
    
    deinit {
        print("deinit")
    }
    
    // User Actions
    @IBAction func doneButtonPressed(_ sender: Any) {
        cleanupBeforeExit()
        dismiss(animated: true, completion: nil)
    }
        
    @IBAction func repeatButtonPressed(_ sender: Any) {
        if repeatButton.currentImage == UIImage(named:"repeat") {
            repeatButton.setImage(UIImage(named:"repeatAll"), for: .normal)
        }else {
            if repeatButton.currentImage == UIImage(named: "repeatAll") {
                repeatButton.setImage(UIImage(named:"repeatCurrent"), for: .normal)
            }else {
                repeatButton.setImage(UIImage(named:"repeat"), for: .normal)
            }
        }
    }
    
    @IBAction func shuffleButtonPressed(_ sender: Any) {
        if shuffleButton.currentImage == UIImage(named: "shuffle") {
            shuffleButton.setImage(UIImage(named:"shuffleOn"), for: .normal)
            dataModel.shuffleQueue()
        }
        else if shuffleButton.currentImage == UIImage(named: "shuffleOn") {
            shuffleButton.setImage(UIImage(named:"shuffle"), for: .normal)
            dataModel.unshuffleQueue()
        }
    }
    
    @IBAction func prevButtonPressed(_ sender: Any) {
        playPreviousSong()
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        if isPaused(){
            playPlayer()
        }else{
            pausePlayer()
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        let index =  dataModel.queuedItems.index(of: player.currentItem!) ?? 0
        if index == dataModel.queuedItems.count - 1 && repeatButton.currentImage != UIImage(named:"repeatCurrent"){
            repeatButton.setImage(UIImage(named:"repeatAll"), for: .normal)
        }
        playNextSong()
    }

    
    // UI Updates
   @objc func loadSong(){
        // Play button image
        configurePlayButton()
    
        if let currentItem = dataModel.currentPlayerItem{
            // Load Image
            loadImage(for:currentItem)
            
            // Load title and artist
            setTitleArtist(for: currentItem)
        }
        
        // Reset Controls
        resetControls()
        
        // Set slider and time labels
        setSliderAndTimeLabels()
        
        // Set lock screen data
        setLockScreenData()
        
        //update background color of up next label view
        playerQueueContainer.header.updateBackgroundColor()
    }
    
    func updatePlayingSong(_ time: CMTime){
        if self.player.currentItem?.status == .readyToPlay{
            let time = CMTimeGetSeconds(self.player.currentTime())
            updateLockScreenTime()
            self.setLabelText(self.timeElapsedLabel, Int(time))
            if !self.sliderDragging {
                self.timeSlider.value = Float(time)
            }
            if self.timeElapsedLabel.text != "--:--" && self.timeElapsedLabel.text == self.durationLabel.text {
                if self.nextButton.isEnabled == true {
                    self.playNextSong()
                }
            }
        }
    }
    
    func isPaused() -> Bool {
        if ((self.player.rate != 0) && (self.player.error == nil)) {
            return false
        }
        else{
            return true
        }
    }
    
    

}
