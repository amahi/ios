//
//  AudioPlayerViewController+Player.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 08. 10..
//  Copyright © 2019. Amahi. All rights reserved.
//
import AVFoundation

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
        
        if dataModel.queuedItems.isEmpty{
            dataModel.resetQueue()
        }
        
        if repeatButton.currentImage == UIImage(named:"repeatCurrent"){
            restartSong()
            return
        }
        
        if let nextItem = dataModel.prepareNext(){
            player.replaceCurrentItem(with: nextItem)
        }else{
            dataModel.resetQueue()
            if let item = dataModel.prepareNext(){
                player.replaceCurrentItem(with: item)
            }else{
                //TODO:- show error
            }
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
            
            if let item = dataModel.preparePrevious(){
                 player.replaceCurrentItem(with: item)
                loadSong()
            }else{
                restartSong()
            }
        }else{
            // Restart song
            restartSong()
        }
    }
    
    
}
