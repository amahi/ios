//
//  RecentFilesViewController+Remote.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 08. 25..
//  Copyright © 2019. Amahi. All rights reserved.
//

import AVFoundation
import GoogleCast

extension RecentFilesViewController{
    
    func playVideoRemotely(mediaURL: URL, mediafile: Recent, queueMedia: QueueMedia) {
        
        // Define media metadata.
        let metadata = GCKMediaMetadata()
        metadata.setString("\(mediafile.fileName)", forKey: kGCKMetadataKeyTitle)
        let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: mediaURL)
        mediaInfoBuilder.streamType = GCKMediaStreamType.none
        mediaInfoBuilder.contentType = "\(mediafile.getExtension())"
        mediaInfoBuilder.metadata = metadata
        mediaInformation = mediaInfoBuilder.build()
        let mediaLoadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
        mediaLoadRequestDataBuilder.mediaInformation = mediaInformation
        
        if let remoteMediaClient = sessionManager.currentCastSession?.remoteMediaClient {
            if queueMedia == .playItem {
                let mediaQueueItemBuilder = GCKMediaQueueItemBuilder()
                mediaQueueItemBuilder.mediaInformation = mediaInformation
                mediaQueueItemBuilder.autoplay = true
                mediaQueueItemBuilder.preloadTime = TimeInterval(UserDefaults.standard.integer(forKey: "preload_time_sec"))
                let mediaQueueItem = mediaQueueItemBuilder.build()
                let queueDataBuilder = GCKMediaQueueDataBuilder(queueType: .generic)
                queueDataBuilder.items = [mediaQueueItem]
                queueDataBuilder.repeatMode = remoteMediaClient.mediaStatus?.queueRepeatMode ?? .off
                
                let mediaLoadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
                mediaLoadRequestDataBuilder.queueData = queueDataBuilder.build()
                
                let request = remoteMediaClient.loadMedia(with: mediaLoadRequestDataBuilder.build())
                request.delegate = self
            }
            else if queueMedia == .queueItem {
                let mediaQueueItemBuilder = GCKMediaQueueItemBuilder()
                mediaQueueItemBuilder.mediaInformation = mediaInformation
                mediaQueueItemBuilder.autoplay = true
                mediaQueueItemBuilder.preloadTime = TimeInterval(UserDefaults.standard.integer(forKey: "preload_time_sec"))
                let mediaQueueItem = mediaQueueItemBuilder.build()
                let request = remoteMediaClient.queueInsert(mediaQueueItem, beforeItemWithID: kGCKMediaQueueInvalidItemID)
                request.delegate = self
                let message = "Selected media addded to queue."
                Toast.displayMessage(message, for: 3, in: appDelegate?.window)
            }
        }
    }
    
    func playAudioRemotely(mediaURL: URL, mediafile: AVPlayerItem, queueMedia: QueueMedia) {
        
        var track: String = ""
        var artist: String = ""
        
        let asset:AVAsset = AVAsset(url:mediaURL)
        for metaDataItems in asset.commonMetadata {
            if metaDataItems.commonKey == AVMetadataKey.commonKeyArtist {
                track = metaDataItems.value as! String
            }
            if metaDataItems.commonKey == AVMetadataKey.commonKeyTitle {
                artist = metaDataItems.value as! String
            }
        }
        let metadata = GCKMediaMetadata()
        metadata.setString("\(artist)", forKey: kGCKMetadataKeyTitle)
        metadata.setString("\(track)", forKey: kGCKMetadataKeySubtitle)
        metadata.addImage(GCKImage(url: URL(string:"http://alpha.amahi.org/cast/audio-play.jpg")!, width: 480, height: 720))
        let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: mediaURL)
        mediaInfoBuilder.streamType = GCKMediaStreamType.none
        mediaInfoBuilder.metadata = metadata
        mediaInformation = mediaInfoBuilder.build()
        let mediaLoadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
        mediaLoadRequestDataBuilder.mediaInformation = mediaInformation
        if let remoteMediaClient = sessionManager.currentCastSession?.remoteMediaClient {
            if queueMedia == .playItem {
                let mediaQueueItemBuilder = GCKMediaQueueItemBuilder()
                mediaQueueItemBuilder.mediaInformation = mediaInformation
                mediaQueueItemBuilder.autoplay = true
                mediaQueueItemBuilder.preloadTime = TimeInterval(UserDefaults.standard.integer(forKey: "preload_time_sec"))
                let mediaQueueItem = mediaQueueItemBuilder.build()
                let queueDataBuilder = GCKMediaQueueDataBuilder(queueType: .generic)
                queueDataBuilder.items = [mediaQueueItem]
                queueDataBuilder.repeatMode = remoteMediaClient.mediaStatus?.queueRepeatMode ?? .off
                
                let mediaLoadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
                mediaLoadRequestDataBuilder.queueData = queueDataBuilder.build()
                
                let request = remoteMediaClient.loadMedia(with: mediaLoadRequestDataBuilder.build())
                request.delegate = self
            }
            else if queueMedia == .queueItem {
                let mediaQueueItemBuilder = GCKMediaQueueItemBuilder()
                mediaQueueItemBuilder.mediaInformation = mediaInformation
                mediaQueueItemBuilder.autoplay = true
                mediaQueueItemBuilder.preloadTime = TimeInterval(UserDefaults.standard.integer(forKey: "preload_time_sec"))
                let mediaQueueItem = mediaQueueItemBuilder.build()
                let request = remoteMediaClient.queueInsert(mediaQueueItem, beforeItemWithID: kGCKMediaQueueInvalidItemID)
                request.delegate = self
                let message = "Selected media addded to queue."
                Toast.displayMessage(message, for: 3, in: appDelegate?.window)
            }
        }
    }
    
}
