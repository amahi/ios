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
    public static let playerQueueDidReset = NSNotification.Name("playerQueueDidReset")
}

class AudioPlayerDataModel{
    private init(){
    }
    
    public static let shared = AudioPlayerDataModel()
    
    var currentPlayerItem:AVPlayerItem?
    var currentIndex = 0
    var startIndex = 0
    var totalFetchedSongs = 0
    var isFetchingMetadata = false
    private var queueDidReset = false
    var unshuffledItems : [AVPlayerItem] = []
    var metadata : [AVPlayerItem:AudioPlayerMetadata] = [:]
    var nowPlayingInfo : [String: Any] = [:]
    var playerItems : [AVPlayerItem] = []
    
    func configure(items:[AVPlayerItem], with startIndex: Int){
        currentPlayerItem = items[startIndex]
        currentIndex = startIndex
        self.startIndex = startIndex
        playerItems = items
        unshuffledItems = items
        totalFetchedSongs = 0
        fetchMetaData(from:currentIndex,to: min(currentIndex+2, playerItems.count - 1 ))
    }
    
    func shuffleQueue(){
        var items = Array(playerItems.prefix(upTo: currentIndex+1))

        for index in 0..<playerItems.count{
            if index <= currentIndex{
                playerItems.removeFirst()
            }
            break
        }
        let shuffled = playerItems.shuffled()
        items.append(contentsOf: shuffled)
        
        playerItems = items

        NotificationCenter.default.post(name: .audioPlayerShuffleStatusChangedNotification, object: self)
    }
    
    func unshuffleQueue(){
        playerItems = unshuffledItems
        if let item = currentPlayerItem{
            currentIndex = playerItems.firstIndex(of: item) ?? currentIndex
        }
        NotificationCenter.default.post(name: .audioPlayerShuffleStatusChangedNotification, object: self)
    }
    
    func resetQueue(){
        currentIndex = 0
        startIndex = 0
        playerItems = unshuffledItems
        currentPlayerItem = playerItems[currentIndex]
        queueDidReset = true
        NotificationCenter.default.post(name: .playerQueueDidReset, object: self)
    }
    
    func prepareNext() -> AVPlayerItem?{
        
        if queueDidReset{
            queueDidReset = false
            currentIndex = 0
            currentPlayerItem = playerItems[currentIndex]
        }else{
            currentIndex += 1
            currentPlayerItem = playerItems[currentIndex]
        }
        NotificationCenter.default.post(name: .audioPlayerQueuedItemsDidUpdateNotification, object: self)
        return currentPlayerItem
    }
    
    func preparePrevious() -> AVPlayerItem?{
        if currentIndex > 0 && currentIndex > startIndex{
            currentIndex -= 1
            currentPlayerItem = playerItems[currentIndex]
            NotificationCenter.default.post(name: .audioPlayerQueuedItemsDidUpdateNotification, object: self)
            return currentPlayerItem
        }
        return nil
    }
    
    func prepareToPlay(at index:Int){
        if index < playerItems.count{
            let item = playerItems.remove(at: index)
            playerItems.insert(item, at: currentIndex+1)
        }
    }
    
    func fetchAndSaveMetaData(for item: AVPlayerItem) -> AudioPlayerMetadata? {
        let metaData = item.asset.metadata
        if metaData.isEmpty{
            return nil
        }
        
        //extracting title
        let title = AudioPlayerDataModel.getTitle(from: metaData)
        
        //extracting artist
        let artist = AudioPlayerDataModel.getArtist(from: metaData)
        
        //extracting thumbnail
        let image = AudioPlayerDataModel.getImage(from: metaData)
        
        let data = AudioPlayerMetadata(image: image, title: title, artist: artist)
        
        metadata[item] = data
        
        return data
    }
    
    func fetchMetaData(from start:Int, to end: Int){
        if start > end || end >= playerItems.count || start < 0 {
            return
        }
        if isFetchingMetadata {
            return
        }
        
        
        isFetchingMetadata = true
        DispatchQueue.global(qos: .background).async { [weak self] in
            var data = [AVPlayerItem: AudioPlayerMetadata]()
            var countFetched = 0
            for index in  start ... end{
                
                if let item = self?.playerItems[index] {
                    let metaData = item.asset.metadata
                    if metaData.isEmpty {
                        continue
                    }
                    //extracting title
                    let title = AudioPlayerDataModel.getTitle(from: metaData)
                    
                    //extracting artist
                    let artist = AudioPlayerDataModel.getArtist(from: metaData)
                    
                    //extracting thumbnail
                    let image = AudioPlayerDataModel.getImage(from: metaData)
                    
                    data[item] = AudioPlayerMetadata(image: image, title: title, artist: artist)
                    countFetched += 1
                    
                }
            }
            DispatchQueue.main.async {
                if let weakSelf = self {
                    data.forEach { (key, value) in
                        weakSelf.metadata[key] = value
                    }
                    
                    weakSelf.totalFetchedSongs += countFetched
                    weakSelf.isFetchingMetadata = false
                    print(weakSelf.metadata)
                    
                    if !data.isEmpty{
                        NotificationCenter.default.post(name: .audioPlayerDidSetMetaData, object: weakSelf)
                    }
                }
            }
        }
    }
    
    func getItemCountForCV() -> Int{
        let totalInFrontFromStartIndex = playerItems.count - startIndex //9
        
        var totalFetchedFromBehind = 0
        
        if totalFetchedSongs > totalInFrontFromStartIndex {
            totalFetchedFromBehind = totalFetchedSongs - totalInFrontFromStartIndex
        }
        
        let totalFetchedFromCurrent = totalFetchedSongs - (currentIndex - startIndex) - totalFetchedFromBehind
        return totalFetchedFromCurrent
    }
    
    func getRowCountForTV() -> Int{
        let totalInFrontFromStartIndex = playerItems.count - startIndex //12
        
        var totalFetchedFromBehind = 0
        
        if totalFetchedSongs > totalInFrontFromStartIndex {
            totalFetchedFromBehind = totalFetchedSongs - totalInFrontFromStartIndex
        }
        
        let totalFetchedFromCurrent = totalFetchedSongs - (currentIndex - startIndex) - totalFetchedFromBehind
        return totalFetchedFromCurrent - 1
    }

    static func getTitle(from metaData:[AVMetadataItem]) -> String{
        var title = "Title"
        for item in metaData {
            if item.commonKey == AVMetadataKey.commonKeyTitle {
                title = (item.value as? String) ?? "Unavailable"
                break
            }
        }
        return title
    }
    
    static func getImage(from metaData:[AVMetadataItem]) -> UIImage{

        var image = UIImage(named: "musicPlayerArtWork") ?? UIImage()
        for item in metaData {
            if item.commonKey == AVMetadataKey.commonKeyArtwork ,
                let data = item.value as? Data,
                let imageFromData =  UIImage(data: data){
                image = imageFromData
                break
            }
        }
        return image
    }
    
    static func getArtist(from metaData:[AVMetadataItem]) -> String{
        var title = "Title"
        for item in metaData {
            if item.commonKey == AVMetadataKey.commonKeyArtist {
                title = (item.value as? String) ?? "Unavailable"
                break
            }
        }
        return title
    }

}

struct AudioPlayerMetadata{
    var image : UIImage?
    var title: String?
    var artist : String?
}
