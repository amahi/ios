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

class AudioPlayerViewController: UIViewController {
    
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
    
    public var player: AVPlayer!
    public var playerItems: [AVPlayerItem]!
    public var itemURLs: [URL]!
    var startPlayerItem: AVPlayerItem!
    
    var sliderDragging = false
    var songDuration = 0.0
    
    var shuffledArray = [Int]()
    var lastSongIndex = 0
    var elapsedTime = 0
    
    var nowPlayingInfo = [String: Any]()
    
    var startedPlayer = false
    var offlineMode = false
    
    var trackNames = [AVPlayerItem: String]()
    var artistNames = [AVPlayerItem: String]()
    var durations = [AVPlayerItem: CMTime]()
    
    var interactor:Interactor? = nil
    var observer: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player = AVPlayer(playerItem: startPlayerItem)
        player.automaticallyWaitsToMinimizeStalling = false
        AppUtility.lockOrientation(.portrait)
        timeSlider.setThumbImage(UIImage(named: "sliderKnobIcon"), for: .normal)
        timeSlider.addTarget(self, action: #selector(timeSliderChanged(slider:event:)), for: .valueChanged)
        
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
        
        if offlineMode{
            loadSong()
            playPlayer()
            observer = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { [weak self] (time) in
                self?.updatePlayingSong(time)
            })
        }
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
            shuffle()
        }
        else {
            shuffleButton.setImage(UIImage(named:"shuffle"), for: .normal)
        }
    }
    
    func shuffle() {
        shuffledArray = stride(from: 0, through: playerItems.count - 1, by: 1).shuffled()
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
        let index =  playerItems.index(of: player.currentItem!) ?? 0
        if index == playerItems.count - 1 && repeatButton.currentImage != UIImage(named:"repeatCurrent"){
            repeatButton.setImage(UIImage(named:"repeatAll"), for: .normal)
        }
        
        playNextSong()
    }

    
    // UI Updates
    func loadSong(){
        // Play button image
        configurePlayButton()
    
        // Load Image
        setImage()
        
        // Reset Controls
        resetControls()
        
        // Load title and artist
        setTitleArtist()
        
        // Set slider and time labels
        setSliderAndTimeLabels()
        
        // Set lock screen data
        setLockScreenData()
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
