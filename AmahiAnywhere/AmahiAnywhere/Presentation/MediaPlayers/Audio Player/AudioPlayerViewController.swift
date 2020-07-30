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
    @IBOutlet weak var thumbnailCollectionView: UICollectionView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var thumbnailCellID = "thumbnailCell"
    
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
        showLoading()
        
        playerQueueContainer = PlayerQueueContainerView(target: self)
        playerQueueContainer.header.arrowHead.addTarget(self, action: #selector(handleArrowHeadTap), for: .touchDown)
        playerQueueContainer.header.tapDelegate = self
        layoutPlayerQueue()
        
                    
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.playerContainer.addGestureRecognizer(panRecognizer)
        panRecognizer.cancelsTouchesInView = true
        
        setupPlayer()
        setupRemoteCommandCenter()
        
        thumbnailCollectionView.register(UINib(nibName: "AudioThumbnailCollectionCell", bundle: nil), forCellWithReuseIdentifier: thumbnailCellID)
        thumbnailCollectionView.delegate = self
        thumbnailCollectionView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCollectionView), name: .audioPlayerShuffleStatusChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMetaData), name: .audioPlayerDidSetMetaData, object: nil)
        
        if offlineMode{
            observer = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { [weak self] (time) in
                self?.updatePlayingSong(time)
            })
        }
        
    }
    
    func setupPlayer(){
        NotificationCenter.default.addObserver(self, selector: #selector(showLoading), name: .AVPlayerItemPlaybackStalled, object: nil)
        
        player = AVPlayer(playerItem: dataModel.currentPlayerItem)
        player.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: [.new], context: nil)
        player.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: [.new], context: nil)
        player.currentItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: [.new], context: nil)
        player.automaticallyWaitsToMinimizeStalling = true
        AppUtility.lockOrientation(.portrait)
        timeSlider.setThumbImage(UIImage(named: "sliderKnobIcon"), for: .normal)
        timeSlider.addTarget(self, action: #selector(timeSliderChanged(slider:event:)), for: .valueChanged)
        
        shuffleButton.setImage(UIImage(named:"shuffle"), for: .normal)
        repeatButton.setImage(UIImage(named:"repeat"), for: .normal)
    }
    
    func setupRemoteCommandCenter(){
        NotificationCenter.default.addObserver(self, selector: #selector(hadleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        
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
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath{
        case "playbackBufferEmpty":
            self.showLoading()
        default:
            if !dataModel.isFetchingMetadata{
                self.loadingIndicator.stopAnimating()
            }
        }
    }
    
    @objc func showLoading(){
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
            self.playerContainer.bringSubviewToFront(self.loadingIndicator)
        }
    }
    
    @objc func refreshCollectionView(){
        thumbnailCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadSong()
        playPlayer()
        if !startedPlayer && !offlineMode{
            startedPlayer = true
            observer = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { [weak self] (time) in
                self?.updatePlayingSong(time)
            })
        }
    }
    
    func cleanupBeforeExit(){
        if player != nil{
            player.pause()
            if let observer = observer{
                player.removeTimeObserver(observer)
            }
        }
        player = nil
        dataModel.isFetchingMetadata = false
        dataModel.totalFetchedSongs = 0
        dataModel.metadata.removeAll()
        NotificationCenter.default.removeObserver(self)
        if let childVC = self.children.first as? AudioPlayerQueueViewController{
            NotificationCenter.default.removeObserver(childVC)
        }
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
        if dataModel.currentIndex == dataModel.playerItems.count - 1,repeatButton.currentImage != UIImage(named:"repeatCurrent"){
            repeatButton.setImage(UIImage(named:"repeatAll"), for: .normal)
        }
        playNextSong()
    }

    @objc func updateMetaData(){
        loadMetadata()
        thumbnailCollectionView.reloadData()
        loadingIndicator.stopAnimating()
    }
    
    // UI Updates
   func loadSong(){
        resetControls()
        loadMetadata()
    }
    
    func loadMetadata(){
        // Play button image
        configurePlayButton()
    
        // Load title and artist
        setTitleArtist()
        
        // Load Image Background
        loadImageBackground()
        
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
            loadingIndicator.stopAnimating()
            return false
        }
        else{
            return true
        }
    }
    
    

}
