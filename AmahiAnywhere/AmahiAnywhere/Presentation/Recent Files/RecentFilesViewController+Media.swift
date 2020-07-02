//
//  RecentFilesViewController+Media.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 08. 25..
//  Copyright © 2019. Amahi. All rights reserved.
//

import Foundation
import AVFoundation

extension RecentFilesViewController{
    
    func playAudio(_ items: [AVPlayerItem], startIndex: Int, currentIndex: Int, _ URLs: [URL]){
        let hasConnectedSession: Bool = (sessionManager.hasConnectedSession())
        if hasConnectedSession, (playbackMode != .remote) {
            let playNow = self.creatAlertAction("Play Now", style: .default) { (action) in
                self.playAudioRemotely(mediaURL: URLs[currentIndex], mediafile: items[currentIndex], queueMedia: .playItem)
                
                }!
            
            let addQueue = self.creatAlertAction("Add to Queue", style: .default) { (action) in
                self.playAudioRemotely(mediaURL: URLs[currentIndex], mediafile: items[currentIndex], queueMedia: .queueItem)
                }!
            
            if sessionManager.currentCastSession?.remoteMediaClient!.mediaQueue.itemCount == 0 {
                addQueue.isEnabled = false
            }
            else {
                addQueue.isEnabled = true
            }
            var actions = [UIAlertAction]()
            actions.append(playNow)
            actions.append(addQueue)
            let cancel = self.creatAlertAction(StringLiterals.cancel, style: .cancel, clicked: nil)!
            actions.append(cancel)
            
            self.createActionSheet(title: "Play Item",
                                   message: "Select an action",
                                   ltrActions: actions,
                                   preferredActionPosition: 0,
                                   sender: filesCollectionView)
            
        }else{
            let audioPlayerVc = self.viewController(viewControllerClass: AudioPlayerViewController.self,
                                                    from: StoryBoardIdentifiers.videoPlayer)
            audioPlayerVc.startPlayerItem = items[startIndex]
            audioPlayerVc.playerItems = items
            audioPlayerVc.itemURLs = URLs
            audioPlayerVc.transitioningDelegate = self
            audioPlayerVc.interactor = interactor
            present(audioPlayerVc, animated: true, completion: nil)
        }
    }
    
    func playMediaItem(recentFile: Recent){
        if let url = URL(string: recentFile.fileURL){
            let hasConnectedSession: Bool = (sessionManager.hasConnectedSession())
            if hasConnectedSession, (playbackMode != .remote) {
                let playNow = self.creatAlertAction("Play Now", style: .default) { (action) in
                    self.playVideoRemotely(mediaURL: url, mediafile: recentFile, queueMedia: .playItem)
                    }!
                
                let addQueue = self.creatAlertAction("Add to Queue", style: .default) { (action) in
                    self.playVideoRemotely(mediaURL: url, mediafile: recentFile, queueMedia: .queueItem)
                    }!
                
                if sessionManager.currentCastSession?.remoteMediaClient!.mediaQueue.itemCount == 0 {
                    addQueue.isEnabled = false
                }
                else {
                    addQueue.isEnabled = true
                }
                var actions = [UIAlertAction]()
                actions.append(playNow)
                actions.append(addQueue)
                let cancel = self.creatAlertAction(StringLiterals.cancel, style: .cancel, clicked: nil)!
                actions.append(cancel)
                
                self.createActionSheet(title: "Play Item",
                                       message: "Select an action",
                                       ltrActions: actions,
                                       preferredActionPosition: 0,
                                       sender: filesCollectionView)
            }else{
                let videoPlayerVc = self.viewController(viewControllerClass: VideoPlayerViewController.self, from: StoryBoardIdentifiers.videoPlayer)
                videoPlayerVc.mediaURL = url
                present(videoPlayerVc, animated: true, completion: nil)
            }
        }
    }
    
    func webViewOpenContent(at url: URL, mimeType: MimeType) {
        let webViewVc = viewController(viewControllerClass: WebViewController.self,
                                       from: StoryBoardIdentifiers.main)
        webViewVc.url = url
        webViewVc.mimeType = mimeType
        webViewVc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(webViewVc, animated: true)
    }
    
}
