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
        if let image = musicArtImageView.image{
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                return image
            })
        }
        
        // Setting title
        nowPlayingInfo[MPMediaItemPropertyTitle] = songTitle.text ?? ""
        nowPlayingInfo[MPMediaItemPropertyArtist] = artistName.text ?? ""
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Int(CMTimeGetSeconds(self.player!.currentTime()))
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = songDuration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPaused() ? 0 : 1
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func updateLockScreenTime(){
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Int(CMTimeGetSeconds(self.player!.currentTime()))
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPaused() ? 0 : 1
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    @objc func remotePlayPause(){
        if isPaused(){
            playPlayer()
        }else{
            pausePlayer()
        }
    }
    
    @objc func remoteNext(){
        playNextSong()
    }
    
    @objc func remotePrevious(){
        playPreviousSong()
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
