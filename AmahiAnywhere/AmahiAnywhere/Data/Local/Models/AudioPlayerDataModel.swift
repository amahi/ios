//
//  AudioPlayerDataModel.swift
//  AmahiAnywhere
//
//  Created by Shresth Pratap Singh on 08/07/20.
//  Copyright © 2020 Amahi. All rights reserved.
//

import Foundation
import AVFoundation

extension Notification.Name{
    public static let audioPlayerShuffleStatusChangedNotification = Notification.Name("audioPlayerQueueShuffleStatusChangedNotification")
    public static let audioPlayerQueuedItemsDidUpdateNotification = NSNotification.Name("audioPlayerQueuedItemsDidUpdateNotification")
    public static let audioPlayerDidSetMetaData = NSNotification.Name("audioPlayerDidSetMetaData")
}

class AudioPlayerDataModel{
    private init(){
    }
    
    public static let shared = AudioPlayerDataModel()
    
    var itemURLs = [URL]()
    var startPlayerItem: AVPlayerItem?
    var currentPlayerItem:AVPlayerItem?
    var shuffledArray : [Int] = []
    
    var trackNames : [AVPlayerItem: String] = [:]
    var artistNames : [AVPlayerItem: String] = [:]
    var thumbnailImages : [AVPlayerItem:UIImage] = [:]
    var durations : [AVPlayerItem: CMTime] = [:]
    var nowPlayingInfo : [String: Any] = [:]
    
    var unshuffledQueueItems : [AVPlayerItem] = []
    var queuedItems : [AVPlayerItem] = []
    var previousItems : [AVPlayerItem] = []
    
    
    
    func shuffleQueue(){
        queuedItems = queuedItems.shuffled()
        NotificationCenter.default.post(name: .audioPlayerShuffleStatusChangedNotification, object: self)
    }
    
    func unshuffleQueue(){
        if let item = currentPlayerItem,let index = unshuffledQueueItems.index(of: item){
            queuedItems = Array(unshuffledQueueItems.suffix(from: index + 1))
        }
        NotificationCenter.default.post(name: .audioPlayerShuffleStatusChangedNotification, object: self)
    }
    
    func resetQueue(){
        queuedItems = unshuffledQueueItems
        previousItems.removeAll()
        NotificationCenter.default.post(name: .audioPlayerQueuedItemsDidUpdateNotification, object: self)
    }
    
    func prepareNext() -> AVPlayerItem?{
        if let item = currentPlayerItem{
            previousItems.insert(item, at: 0)
        }
        if !queuedItems.isEmpty{
            currentPlayerItem = queuedItems.removeFirst()
        }
        NotificationCenter.default.post(name: .audioPlayerQueuedItemsDidUpdateNotification, object: self)
        return currentPlayerItem
    }
    
    func preparePrevious() -> AVPlayerItem?{
        if let current = currentPlayerItem, !previousItems.isEmpty{
            queuedItems.insert(current, at: 0)
            currentPlayerItem = previousItems.removeFirst()
            NotificationCenter.default.post(name: .audioPlayerQueuedItemsDidUpdateNotification, object: self)
            return currentPlayerItem
        }
        return nil
    }
    
    func setupQueueMetadata(){
        DispatchQueue.global(qos: .userInitiated).async {
            for item in self.queuedItems{
                let metaData = item.asset.metadata
                
                //extracting title
                let titleMetaData = AVMetadataItem.metadataItems(from: metaData, filteredByIdentifier: .commonIdentifierTitle)
                if let title = titleMetaData.first, let titleString = title.value as? String{
                    self.trackNames[item] = titleString
                }
                
                //extracting artist
                let artistMetaData = AVMetadataItem.metadataItems(from: metaData, filteredByIdentifier: .commonIdentifierArtist)
                if let artist = artistMetaData.first, let artistString = artist.value as? String{
                    self.artistNames[item] = artistString
                }
                
                //extracting thumbnail
                let imageMetaData = AVMetadataItem.metadataItems(from: metaData, filteredByIdentifier: .commonIdentifierArtwork)
                if let imageData = imageMetaData.first?.dataValue, let image = UIImage(data: imageData){
                    self.thumbnailImages[item] = image
                }
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .audioPlayerDidSetMetaData, object: self)
            }
        }
    }
}
