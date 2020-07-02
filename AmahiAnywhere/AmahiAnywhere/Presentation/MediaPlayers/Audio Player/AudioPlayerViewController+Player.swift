//
//  AudioPlayerViewController+Player.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 08. 10..
//  Copyright © 2019. Amahi. All rights reserved.
//

extension AudioPlayerViewController{
    
    func playPlayer(){
        if isPaused(){
            player.play()
            player.rate = 1
            configurePlayButton()
        }
    }
    
    func pausePlayer(){
        if !isPaused(){
            player.pause()
            player.rate = 0
            configurePlayButton()
        }
    }
    
    func restartSong(){
        timeSlider.value = 0
        player.seek(to: .zero)
    }
    
    
    func playNextSong(){
        if repeatButton.currentImage == UIImage(named:"repeatCurrent"){
            restartSong()
            return
        }
        
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
        }else{
            var index =  playerItems.firstIndex(of: player.currentItem!) ?? 0
            if index == playerItems.count - 1 {
                index = 0
            }else {
                index = index + 1
            }
            
            player.replaceCurrentItem(with: playerItems[index])
        }
        
        loadSong()
    }
    
    func playPreviousSong(){
        if repeatButton.currentImage == UIImage(named:"repeatCurrent"){
            restartSong()
            return
        }
        
        if timeElapsedLabel.text == "00:00" || timeElapsedLabel.text == "00:01" || timeElapsedLabel.text == "00:02"{
            // Previous song
            var index =  playerItems.firstIndex(of: player.currentItem!) ?? 0
            
            if index == 0 {
                index = playerItems.count - 1
            }else {
                index = index - 1
            }
            
            player.replaceCurrentItem(with: playerItems[index])
            loadSong()
        }else{
            // Restart song
            restartSong()
        }
    }
    
    
}
