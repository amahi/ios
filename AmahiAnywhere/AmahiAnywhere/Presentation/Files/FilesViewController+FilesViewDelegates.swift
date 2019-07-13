//
//  FilesViewController+FilesViewDelegates.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/17/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import AVKit
import Foundation
import MediaPlayer
import GoogleCast

// MARK: Files View implementations

extension FilesViewController: FilesView {
    
    func dismissProgressIndicator(at url: URL, completion: @escaping () -> Void) {
        downloadProgressAlertController?.dismiss(animated: true, completion: {
            completion()
        })
        downloadProgressAlertController = nil
        progressView = nil
        isAlertShowing = false
    }
    
    func updateDownloadProgress(for row: Int, section: Int, downloadJustStarted: Bool , progress: Float) {
        
        if downloadJustStarted {
            setupDownloadProgressIndicator()
            let file = self.filteredFiles.getFileFromIndexPath(IndexPath(row: row, section: section))
            downloadProgressAlertController?.title = String(format: StringLiterals.downloadingFile, file.name!)
        }
        
        if !isAlertShowing {
            self.isAlertShowing = true
            present(downloadProgressAlertController!, animated: true, completion: nil)
        }
        
        progressView?.setProgress(progress, animated: true)
    }
    
    func shareFile(at url: URL, from sender : UIView? ) {
        let linkToShare = [url]
        
        let activityController = UIActivityViewController(activityItems: linkToShare, applicationActivities: nil)
        if let popoverController = activityController.popoverPresentationController, let sender = sender {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        self.present(activityController, animated: true, completion: nil)
    }
    
    func webViewOpenContent(at url: URL, mimeType: MimeType) {
        let webViewVc = self.viewController(viewControllerClass: WebViewController.self,
                                            from: StoryBoardIdentifiers.main)
        webViewVc.url = url
        webViewVc.mimeType = mimeType
        webViewVc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(webViewVc, animated: true)
    }
    
    func playMedia(at url: URL, file: ServerFile) {
        let hasConnectedSession: Bool = (sessionManager.hasConnectedSession())
        if hasConnectedSession, (playbackMode != .remote) {
            playVideoRemotely(mediaURL: url, mediafile: file)
            
        }
        else if sessionManager.currentSession == nil, (playbackMode != .local) {
            let videoPlayerVc = self.viewController(viewControllerClass: VideoPlayerViewController.self,
                                                    from: StoryBoardIdentifiers.videoPlayer)
            videoPlayerVc.mediaURL = url
            self.present(videoPlayerVc)
            
        }
    }
    
    func playVideoRemotely(mediaURL: URL, mediafile: ServerFile) {
        GCKCastContext.sharedInstance().presentDefaultExpandedMediaControls()
        
        // Define media metadata.
        let metadata = GCKMediaMetadata()
        //let image = VideoThumbnailGenerator().getThumbnail(mediaURL)
        metadata.setString("\(mediafile.name!)", forKey: kGCKMetadataKeyTitle)
        let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: mediaURL)
        mediaInfoBuilder.streamType = GCKMediaStreamType.none
        mediaInfoBuilder.contentType = "\(mediafile.getExtension())"
        mediaInfoBuilder.metadata = metadata
        mediaInformation = mediaInfoBuilder.build()
        
        let mediaLoadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
        mediaLoadRequestDataBuilder.mediaInformation = mediaInformation
        
        // Send a load request to the remote media client.
        if let request = sessionManager.currentSession?.remoteMediaClient?.loadMedia(with: mediaLoadRequestDataBuilder.build()) {
            request.delegate = self
        }
    }
    
    func playAudio(_ items: [AVPlayerItem], startIndex: Int, currentIndex: Int,_ URLs: [URL]) {
        
        let hasConnectedSession: Bool = (sessionManager.hasConnectedSession())
        if hasConnectedSession, (playbackMode != .remote) {
            playAudioRemotely(mediaURL: URLs[currentIndex], mediafile: items[currentIndex])
            
        }
        else if sessionManager.currentSession == nil, (playbackMode != .local) {
            player = AVPlayer.init(playerItem: items[currentIndex])
            let audioPlayerVc = self.viewController(viewControllerClass: AudioPlayerViewController.self,
                                                    from: StoryBoardIdentifiers.videoPlayer)
            audioPlayerVc.player = self.player
            audioPlayerVc.playerItems = items
            audioPlayerVc.itemURLs = URLs
            player.play()
            self.present(audioPlayerVc)
            
        }
    }
    
    func playAudioRemotely(mediaURL: URL, mediafile: AVPlayerItem) {
        GCKCastContext.sharedInstance().presentDefaultExpandedMediaControls()
        
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
        if let request = sessionManager.currentSession?.remoteMediaClient?.loadMedia(with: mediaLoadRequestDataBuilder.build()) {
            request.delegate = self
        }
    }
    
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        let affectedKeyPathsMappingByKey: [String: Set<String>] = [
            "rate":         [#keyPath(FilesViewController.player.rate)]
        ]
        
        return affectedKeyPathsMappingByKey[key] ?? super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Make sure the this KVO callback was intended for this view controller.
        let ctx = context
        guard ctx == &playerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: ctx)
            return
        }
        
        if keyPath == #keyPath(FilesViewController.player.rate) {
            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
            guard player != nil else { return }
            
            AmahiLogger.log("CURRENT RATE IS \(newRate)")
            
            if newRate == 0.0 {
                
                if let currentItem = player.currentItem {
                    guard currentItem.currentTime() == currentItem.duration else { return }
                    AmahiLogger.log("ENTERED LAST BLOCK")
                    currentItem.seek(to: CMTime.zero)
                    self.player.play()
                }
            }
        }
    }
    
    func present(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }
    
    func initFiles(_ files: [ServerFile]) {
        self.serverFiles = files
    }
    
    func updateFiles(_ files: [ServerFile]) {
        // Organsing files into sections using filteredFiles
        filteredFiles.reset()
        let files = files.sorted(by: getSorter(fileSort))
        
        if fileSort == .name{
            organizeSectionsByName(files: files)
        }else if fileSort == .date{
            organizeSectionsByModified(files: files)
        }else if fileSort == .size{
            organizeSectionsBySize(files: files)
        }else{
            organizeSectionsByType(files: files)
        }
        
        filesCollectionView.reloadData()
    }
    
    func updateRefreshing(isRefreshing: Bool) {
        if isRefreshing {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}
