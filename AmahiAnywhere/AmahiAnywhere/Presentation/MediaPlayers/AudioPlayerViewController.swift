//
//  AudioPlayerViewController.swift
//  AmahiAnywhere
//
//  Created by Abhishek Sansanwal on 06/06/19.
//  Copyright © 2019 Amahi. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class AudioPlayerViewController: UIViewController {
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var musicArtImageView: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var audioControlsView: UIView!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    
    public var player: AVPlayer!
    public var playerItems: [AVPlayerItem]!
    public var itemURLs: [URL]!
    
    let commandCenter = MPRemoteCommandCenter.shared()
    
    var nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    var remoCommandCenter = MPRemoteCommandCenter.shared()
    var shuffledArray: [Int] = []
    var lastSongIndex: Int = 0
    var songDuration: Int = 0
    var elapsedTime: Int = 0
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        player.pause()
        player = nil
        AppUtility.lockOrientation(.all)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func repeatButtonPressed(_ sender: Any) {
        if repeatButton.currentImage == UIImage(named:"repeat") {
            repeatButton.setImage(UIImage(named:"repeatAll"), for: .normal)
        }
        else {
            if repeatButton.currentImage == UIImage(named: "repeatAll") {
                 repeatButton.setImage(UIImage(named:"repeatCurrent"), for: .normal)
            }
            else {
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
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        if playPauseButton.currentImage == UIImage(named: "playIcon") {
            player.play()
            configurePlayButton()
        }
        else{
            player.pause()
            configurePlayButton()
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
       var index =  playerItems.index(of: player.currentItem!) ?? 0
        if index == playerItems.count - 1 {
            repeatButton.setImage(UIImage(named:"repeatAll"), for: .normal)
        }
       playNextSong()
    }
    
    @IBAction func prevButtonPressed(_ sender: Any) {
        playPrevSong()
    }
    
    func playNextSong() {
        
        if repeatButton.currentImage == UIImage(named:"repeat") {
            if player?.timeControlStatus == .playing {
                self.player.pause()
            }
            configurePlayButton()
            player.seek(to: CMTime.zero)
            
            if shuffleButton.currentImage == UIImage(named: "shuffleOn") {
                
                if shuffledArray.count == 1 {
                    lastSongIndex = shuffledArray[0]
                }
                if shuffledArray.count == 0 {
                    shuffle()
                    if shuffledArray[0] == lastSongIndex {
                        shuffledArray.removeFirst()
                    }
                }
                player.replaceCurrentItem(with: playerItems[shuffledArray[0]])
                shuffledArray.removeFirst()
            }
            else{
                var index =  playerItems.index(of: player.currentItem!) ?? 0
                if index == playerItems.count - 1 {
                    player.pause()
                    configurePlayButton()
                    return
                }
                else {
                    index = index + 1
                }
                player.replaceCurrentItem(with: playerItems[index])
            }
        }
        if repeatButton.currentImage == UIImage(named:"repeatAll") {
            if player?.timeControlStatus == .playing {
                self.player.pause()
            }
            configurePlayButton()
            player.seek(to: CMTime.zero)
            
            if shuffleButton.currentImage == UIImage(named: "shuffleOn") {
                
                if shuffledArray.count == 1 {
                    lastSongIndex = shuffledArray[0]
                }
                if shuffledArray.count == 0 {
                    shuffle()
                    if shuffledArray[0] == lastSongIndex {
                        shuffledArray.removeFirst()
                    }
                }
                player.replaceCurrentItem(with: playerItems[shuffledArray[0]])
                shuffledArray.removeFirst()
            }
            else{
                var index =  playerItems.index(of: player.currentItem!) ?? 0
                if index == playerItems.count - 1 {
                    index = 0
                }
                else {
                    index = index + 1
                }
                player.replaceCurrentItem(with: playerItems[index])
            }
        }
        if repeatButton.currentImage == UIImage(named:"repeatCurrent") {
            let index =  playerItems.index(of: player.currentItem!) ?? 0
            self.player?.seek(to: CMTime.zero)
            player.replaceCurrentItem(with: playerItems[index])
        }
        playSong()
        setArtWork()
        setDurationLabel()
    }
    
    func playPrevSong() {
        player.pause()
        player.rate = 0
        configurePlayButton()
        player.seek(to: CMTime.zero)
        var index =  playerItems.index(of: player.currentItem!) ?? 0
        if index == 0 {
            index = playerItems.count - 1
        }
        else {
            index = index - 1
        }
        player.replaceCurrentItem(with: playerItems[index])
        playSong()
        setArtWork()
        setDurationLabel()
    }
    
    func playSong() {
        player.play()
        setTimeSlider()
        setLockScreenMetadata()
    }
    
    func shuffle() {
        shuffledArray = stride(from: 0, through: playerItems.count - 1, by: 1).shuffled()
    }
    
    func setLockScreenMetadata() {
        var track: String = ""
        var artist: String = ""
        
        let asset:AVAsset = AVAsset(url:itemURLs[playerItems.index(of: player.currentItem!) ?? 0])
        for metaDataItems in asset.commonMetadata {
            //getting the title of the song
            //getting the thumbnail image associated with file
            if metaDataItems.commonKey == AVMetadataKey.commonKeyArtist {
                track = metaDataItems.value as! String
            }
            if metaDataItems.commonKey == AVMetadataKey.commonKeyTitle {
                artist = metaDataItems.value as! String
            }
        }
        artistName.text = artist
        songTitle.text = track
        updateNowPlayingInfo(trackName: track, artistName: artist,img: musicArtImageView.image!)
    }
    
    func setArtWork(){
        DispatchQueue.global(qos: .background).async {
            let image = AudioThumbnailGenerator().getThumbnail(self.itemURLs[self.playerItems.index(of: self.player.currentItem!) ?? 0])
            DispatchQueue.main.async {
                self.musicArtImageView.image = image
                self.setLockScreenMetadata()
            }
        }
    }
    
    func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
        return (seconds / 60, (seconds % 60) % 60)
    }
    
    func setLabelText(_ sender: UILabel!,_ duration: Int) {
        let (m,s) = self.secondsToMinutesSeconds(seconds: Int(duration))
        if m/10 < 1 && s/10 < 1 {
            sender.text = "0\(m):0\(s)"
        }
        else if m/10 < 1 && s/10 >= 1 {
            sender.text = "0\(m):\(s)"
        }
        else if m/10 >= 1 && s/10 < 1 {
            sender.text = "\(m):0\(s)"
        }
        else{
            sender.text = "\(m):\(s)"
        }
    }
    
    func setDurationLabel() {
        self.timeSlider.value = 0.0
        self.durationLabel.text = "--:--"
        self.timeElapsedLabel.text = "--:--"
        DispatchQueue.global(qos: .background).async {
            let duration = CMTimeGetSeconds(self.player.currentItem?.asset.duration ?? CMTime.zero)
            DispatchQueue.main.async {
                self.setLabelText(self.durationLabel, Int(duration))
                self.songDuration = Int(duration)
                self.setLockScreenMetadata()
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
    
    func updateNowPlayingInfo(trackName:String,artistName:String,img:UIImage) {
        var art = MPMediaItemArtwork(image: img)
        if #available(iOS 10.0, *) {
            art = MPMediaItemArtwork(boundsSize: CGSize(width: 200, height: 200)) { (size) -> UIImage in
                return img
            }
        }
        nowPlayingInfoCenter.nowPlayingInfo = [MPMediaItemPropertyTitle: trackName,
                                               MPMediaItemPropertyArtist: artistName,
                                               MPMediaItemPropertyArtwork : art, MPMediaItemPropertyPlaybackDuration: songDuration, MPNowPlayingInfoPropertyPlaybackRate: player.rate = isPaused() ? 0:1 ,MPNowPlayingInfoPropertyElapsedPlaybackTime : elapsedTime] //MPChangePlaybackPositionCommandEvent: ]
        remoCommandCenter.seekForwardCommand.isEnabled = false
        remoCommandCenter.seekBackwardCommand.isEnabled = false
        remoCommandCenter.previousTrackCommand.isEnabled = true
        remoCommandCenter.nextTrackCommand.isEnabled = true
        remoCommandCenter.togglePlayPauseCommand.isEnabled = true
        remoCommandCenter.changePlaybackPositionCommand.isEnabled = true
        remoCommandCenter.changePlaybackPositionCommand.addTarget(self, action:#selector(changePlaybackPositionCommand(_:)))
        UIApplication.shared.beginReceivingRemoteControlEvents()
        becomeFirstResponder()
    }
    
    @objc func changePlaybackPositionCommand(_ event:MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        let time = event.positionTime
        let targetTime:CMTime = CMTimeMake(value: Int64(time), timescale: 1)
        if Int(time) != 0 {
            player!.seek(to: targetTime)
        }
        if player!.rate == 0
        {
            playSong()
        }
        return MPRemoteCommandHandlerStatus.success;
    }
    
    @objc private func playandPause(_ sender: Any) {
        AmahiLogger.log("playandPause was called ")
        
        if !(sender is UIButton) {
            self.player.timeControlStatus == .playing ? self.player.pause() : self.player.play()
        }
    }
    
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleInterruption),
                                       name: AVAudioSession.interruptionNotification,
                                       object: nil)
    }
    
    // Dealing with call interruption
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            // Call received, media playback stopped
        }
        else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    player.play()
                } else {
                    // Playback error
                }
            }
        }
    }
    
    func setTimeSlider() {
        let duration : CMTime = player.currentItem?.asset.duration ?? CMTime.zero
        let seconds : Float64 = CMTimeGetSeconds(duration)
        timeSlider!.maximumValue = Float(seconds)
        timeSlider!.isContinuous = false
        timeSlider?.addTarget(self, action: #selector(timeSliderValueChanged(_:)), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        timeSlider!.minimumValue = 0
        setTimeSlider()
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player?.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                self.setLabelText(self.timeElapsedLabel, Int(time))
                self.timeSlider.value = Float (time )
                if self.timeElapsedLabel.text != "--:--" && self.timeElapsedLabel.text == self.durationLabel.text {
                    if self.nextButton.isEnabled == true {
                        self.playNextSong()
                    }
                }
                self.configurePlayButton()
            }
        }
    }
    
    func configurePlayButton() {
        if ((self.player.rate != 0) && (self.player.error == nil)) {
            self.playPauseButton.setImage(UIImage(named: "pauseIcon"), for: .normal)
        }
        else{
            self.playPauseButton.setImage(UIImage(named: "playIcon"), for: .normal)
        }
    }
    
    @objc func timeSliderValueChanged(_ sender: Any)
    {
        let seconds : Int64 = Int64(timeSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player!.seek(to: targetTime)
        if player!.rate == 0
        {
            playSong()
        }
    }
    
    override func viewDidLoad() {
        AppUtility.lockOrientation(.portrait)
        timeSlider.isUserInteractionEnabled = true
        setDurationLabel()
        setArtWork()
        timeSlider.setThumbImage(UIImage(named: "sliderKnobIcon"), for: .normal)
        self.setLockScreenMetadata()
        setupNotifications()
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget(self, action: #selector(playandPause(_:)))
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(self, action: #selector(nextButtonPressed(_:)))
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(self, action: #selector(prevButtonPressed(_:)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        if canBecomeFirstResponder {
            becomeFirstResponder()
        }
    }
    
}
