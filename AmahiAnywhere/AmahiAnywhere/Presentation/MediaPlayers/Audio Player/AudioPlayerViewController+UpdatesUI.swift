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
    
    func loadImageBackground(){
        if let item = dataModel.currentPlayerItem{
            self.backgroundImageView.image = dataModel.metadata[item]?.image
        }
    }
    
    func setTitleArtist(){
        var track = "Title"
        var artist = "Artist"
        if let item = dataModel.currentPlayerItem{
            track = dataModel.metadata[item]?.title ?? "Title"
            artist = dataModel.metadata[item]?.artist ?? "Artist"
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
        
        let durationCMTime = player.currentItem?.asset.duration ?? CMTime.zero
        duration = CMTimeGetSeconds(durationCMTime)
        
        songDuration = Double(duration)
        self.timeSlider.maximumValue = Float(duration)
        self.timeElapsedLabel.text = "00:00"
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
