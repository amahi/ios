//
//  AudioPlayerViewController + QueueLayout.swift
//  AmahiAnywhere
//
//  Created by Shresth Pratap Singh on 07/06/20.
//  Copyright © 2020 Amahi. All rights reserved.
//

import UIKit
import AVFoundation

extension AudioPlayerViewController: AudioPlayerQueueDelegate {
    
    func layoutPlayerQueue(){
        view.addSubview(playerQueueContainer)
        view.bringSubviewToFront(playerQueueContainer)
        playerQueueContainer.bringSubviewToFront(playerQueueContainer.header)
                
        queueTopConstraintForOpen = self.playerQueueContainer.topAnchor.constraint(equalTo:self.view.bottomAnchor, constant: -queueVCHeight)
        queueTopConstraintForCollapse = self.playerQueueContainer.topAnchor.constraint(equalTo:self.view.bottomAnchor, constant: -65)
        
        queueTopConstraintForCollapse?.isActive = true
        queueTopConstraintForOpen?.isActive = false
        
        
        playerQueueContainer.translatesAutoresizingMaskIntoConstraints = false
        playerQueueContainer.leadingAnchor.constraint(equalTo:self.view.leadingAnchor, constant: 0).isActive = true
        playerQueueContainer.trailingAnchor.constraint(equalTo:self.view.trailingAnchor,constant: 0).isActive = true
        playerQueueContainer.heightAnchor.constraint(equalToConstant: queueVCHeight + 10).isActive = true
        
        playerQueueContainer.layer.cornerRadius = 30
        playerQueueContainer.clipsToBounds = true
        
        playerQueueContainer.layer.shadowPath = UIBezierPath(roundedRect: playerQueueContainer.bounds, cornerRadius: playerQueueContainer.layer.cornerRadius).cgPath
        playerQueueContainer.layer.shadowOpacity = 0.5
        playerQueueContainer.layer.shadowRadius = 5
        playerQueueContainer.layer.shadowColor = UIColor.systemGray.cgColor
        playerQueueContainer.layer.shadowOffset = CGSize(width: 10, height: 10)
        playerQueueContainer.layer.masksToBounds = false
    }
    
    
    //MARK:- Delegate methods
    
    func didDeleteItem(at indexPath: IndexPath) {
    }
    
    func didMoveItem(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }
    
    func shouldPlay(item: AVPlayerItem, at indexPath: IndexPath) {
        player.replaceCurrentItem(with: item)
        loadSong()
    }
    
}
