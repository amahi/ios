//
//  AudioPlayerViewController+UpdatesUI.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 08. 10..
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

extension AudioPlayerViewController{
    
    func setImage(){
        let url = itemURLs[playerItems.index(of: player.currentItem!) ?? 0]
        if let image = AudioThumbnailGenerator.imageFromMemory(for: url){
            loadImage(image: image)
        }else{
            loadImage(image: UIImage(named: "musicPlayerArtWork")!)
        }
    }
    
    func loadImage(image: UIImage){
        self.musicArtImageView.image = image
        self.backgroundImageView.image = image
    }
    
    func setTitleArtist(){
        var track: String?
        var artist: String?
        
        if let trackName = trackNames[player.currentItem!], let artistName = artistNames[player.currentItem!]{
            track = trackName
            artist = artistName
        }else{
            let asset:AVAsset = AVAsset(url:itemURLs[playerItems.index(of: player.currentItem!) ?? 0])
            let metaData = asset.metadata
            
            let artistNameMetaData = AVMetadataItem.metadataItems(from: metaData, filteredByIdentifier: AVMetadataIdentifier.commonIdentifierArtist)
            if let artistName = artistNameMetaData.first{
                artist = artistName.value as? String
                artistNames[player.currentItem!] = artist
            }
            
            let titleMetaData = AVMetadataItem.metadataItems(from: metaData, filteredByIdentifier: AVMetadataIdentifier.commonIdentifierTitle)
            if let title = titleMetaData.first{
                track = title.value as? String
                trackNames[player.currentItem!] = track
            }
        }
        
        artistName.text = artist
        songTitle.text = track
    }
    
    func resetControls(){
        player.seek(to: .zero)
        timeSlider.value = 0
        timeElapsedLabel.text = "--:--"
        durationLabel.text = "--:--"
    }
    
    func setSliderAndTimeLabels(){
        var duration: Float64 = 0.0
        
        if let durationCMTime = durations[player.currentItem!]{
            duration = CMTimeGetSeconds(durationCMTime)
        }else{
            let durationCMTime = player.currentItem?.asset.duration ?? CMTime.zero
            durations[player.currentItem!] = durationCMTime
            duration = CMTimeGetSeconds(durationCMTime)
        }
        
        songDuration = Double(duration)
        self.timeSlider.maximumValue = Float(duration)
        self.timeElapsedLabel.text = "0:00"
        self.setLabelText(self.durationLabel, Int(duration))
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
    
    func configurePlayButton() {
        if isPaused() {
            self.playPauseButton.setImage(UIImage(named: "playIcon"), for: .normal)
        }else{
            self.playPauseButton.setImage(UIImage(named: "pauseIcon"), for: .normal)
        }
    }
    
    @objc func timeSliderChanged(slider: UISlider, event: UIEvent){
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                sliderDragging = true
            case .moved:
                setLabelText(timeElapsedLabel, Int(slider.value))
            case .ended:
                let seconds = Int64(timeSlider.value)
                let targetTime = CMTimeMake(value: seconds, timescale: 1)
                player.seek(to: targetTime) { (_) in
                    self.sliderDragging = false
                }
            default:
                break
            }
        }
    }
}
