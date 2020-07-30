//
//  AudioPlayerViewController+Remote.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 08. 10..
//  Copyright © 2019. Amahi. All rights reserved.
//

import AVFoundation
import MediaPlayer

extension AudioPlayerViewController{
    
    func setLockScreenData(){
        // Setting image
        var lockScreenImage = UIImage(named:"musicPlayerArtWork") ?? UIImage()
        if let item = dataModel.currentPlayerItem, let image = dataModel.metadata[item]?.image{
            lockScreenImage = image
        }
        dataModel.nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: lockScreenImage.size, requestHandler: { (size) -> UIImage in
            return lockScreenImage
        })
        
        // Setting title
        dataModel.nowPlayingInfo[MPMediaItemPropertyTitle] = songTitle.text ?? ""
        dataModel.nowPlayingInfo[MPMediaItemPropertyArtist] = artistName.text ?? ""
        dataModel.nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = songDuration
        dataModel.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPaused() ? 0 : 1
        MPNowPlayingInfoCenter.default().nowPlayingInfo = dataModel.nowPlayingInfo
        
        let elapsedTime = CMTimeGetSeconds(self.player!.currentTime())
        guard !elapsedTime.isNaN else {
            return
        }
        dataModel.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Int(elapsedTime)
    }
    
    func updateLockScreenTime(){
        dataModel.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Int(CMTimeGetSeconds(self.player!.currentTime()))
        dataModel.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPaused() ? 0 : 1
        MPNowPlayingInfoCenter.default().nowPlayingInfo = dataModel.nowPlayingInfo
    }
    
    @objc func remotePlayPause() -> MPRemoteCommandHandlerStatus{
        if isPaused(){
            playPlayer()
        }else{
            pausePlayer()
        }
        return .success
    }
    
    @objc func remoteNext() -> MPRemoteCommandHandlerStatus{
        playNextSong()
        return .success
    }
    
    @objc func remotePrevious() -> MPRemoteCommandHandlerStatus{
        playPreviousSong()
        return .success
    }
    
    @objc func remoteChangedPlaybackPositionCommand(_ event:MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus {
        let time = event.positionTime
        let targetTime = CMTimeMake(value: Int64(time), timescale: 1)
        player.seek(to: targetTime)
        self.timeSlider.value = Float(CMTimeGetSeconds(targetTime))
        return .success
    }
    
    // Call interruption
    @objc func hadleInterruption(notification: Notification){
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        
        if type == .began {
            // Call received, media playback stopped
            pausePlayer()
        }else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    playPlayer()
                }else {
                    // Playback error
                }
            }
        }
    }
}
