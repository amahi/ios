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
    
    func setupQueueConstraints(){
        view.addSubview(playerQueueContainer)
        layoutPlayerQueue()
    }
    
    func layoutPlayerQueue(){
        view.bringSubviewToFront(playerQueueContainer)
        playerQueueContainer.bringSubviewToFront(playerQueueContainer.header)
                
        queueTopConstraintForOpen = self.playerQueueContainer.topAnchor.constraint(equalTo:self.view.bottomAnchor, constant: -viewSize.height * 0.72)
        queueTopConstraintForCollapse = self.playerQueueContainer.topAnchor.constraint(equalTo:self.view.bottomAnchor, constant: -65)
        
        queueTopConstraintForOpen?.isActive = false
        queueTopConstraintForCollapse?.isActive = true
        
        
        playerQueueContainer.translatesAutoresizingMaskIntoConstraints = false
        playerQueueContainer.leadingAnchor.constraint(equalTo:self.view.leadingAnchor, constant: 0).isActive = true
        playerQueueContainer.trailingAnchor.constraint(equalTo:self.view.trailingAnchor,constant: 0).isActive = true
        playerQueueContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        playerQueueContainer.layer.cornerRadius = 30
        playerQueueContainer.clipsToBounds = true
        
        playerQueueContainer.layer.shadowPath = UIBezierPath(roundedRect: playerQueueContainer.bounds, cornerRadius: playerQueueContainer.layer.cornerRadius).cgPath
        playerQueueContainer.layer.shadowOpacity = 0.5
        playerQueueContainer.layer.shadowRadius = 5
        playerQueueContainer.layer.shadowColor = UIColor.systemGray.cgColor
        playerQueueContainer.layer.shadowOffset = CGSize(width: 10, height: 10)
        playerQueueContainer.layer.masksToBounds = false
    }
    
    func resetQueueConstraints(){
        
        playerQueueContainer.removeFromSuperview()
        
        
        setupQueueConstraints()
        
        
        switch self.currentQueueState{
        case .collapsed:
            self.queueTopConstraintForOpen?.isActive = false
            self.queueTopConstraintForCollapse?.isActive = true
            self.playerQueueContainer.header.alpha = 1
            
            self.playerQueueContainer.clipsToBounds = true
            self.playerQueueContainer.layer.cornerRadius = 0
            self.playerQueueContainer.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]

        case .open:
            self.queueTopConstraintForCollapse?.isActive = false
            self.queueTopConstraintForOpen?.isActive = true
            self.playerQueueContainer.header.alpha = 1
            
            self.playerQueueContainer.clipsToBounds = true
            self.playerQueueContainer.layer.cornerRadius = 30
            self.playerQueueContainer.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]

        }
    }
    
    
    //MARK:- Delegate methods
    
    func didDeleteItem(at indexPath: IndexPath) {
        thumbnailCollectionView.reloadData()
    }
    
    func didMoveItem(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        thumbnailCollectionView.reloadData()
    }
    
    func shouldPlay(item: AVPlayerItem, at indexPath: IndexPath) {
        
    }
    
}
