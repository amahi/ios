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
    
    
    func playNextSong(whileOverridingRepeatCurrent: Bool = false){
        
        if repeatButton.currentImage == UIImage(named:"repeatCurrent"), !whileOverridingRepeatCurrent{
            restartSong()
            return
        }
        
        if dataModel.currentIndex >= dataModel.playerItems.count - 1{
            
            //current queue is empty resetting queue
            dataModel.resetQueue()
            repeatButton.setImage(UIImage(named:"repeatAll"), for: .normal)
            shuffleButton.setImage(UIImage(named: "shuffle"), for: .normal)
            player.replaceCurrentItem(with: dataModel.prepareNext())
            thumbnailCollectionView.reloadData()
            loadSong()
            return
        }
        
        player.replaceCurrentItem(with: dataModel.prepareNext())
        updateThumbnailCollectionView(for: .next)
        loadSong()
    }
    
    func playPreviousSong(fromSwipe:Bool = false){
        if repeatButton.currentImage == UIImage(named:"repeatCurrent"){
            restartSong()
            return
        }
        
        let allowedTimeLimits = ["00:00","00:01","00:02","00:03","00:04","00:05"]
        
        if allowedTimeLimits.contains(timeElapsedLabel.text ?? "") || fromSwipe{
            // Previous song
            
            if let item = dataModel.preparePrevious(){
                updateThumbnailCollectionView(for: .previous)
                player.replaceCurrentItem(with: item)
                loadSong()
            }
        }else{
            // Restart song
            restartSong()
        }
    }
    
    
}
