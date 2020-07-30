//
//  OfflineFilesViewController+FilesView.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 28..
//  Copyright © 2019. Amahi. All rights reserved.
//

import Foundation
import AVFoundation

extension OfflineFilesViewController : OfflineFilesView {
    
    func present(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }
    
    func webViewOpenContent(at url: URL, mimeType: MimeType) {
        let webViewVc = self.viewController(viewControllerClass: WebViewController.self,
                                            from: StoryBoardIdentifiers.main)
        webViewVc.url = url
        webViewVc.mimeType = mimeType
        self.navigationController?.pushViewController(webViewVc, animated: true)
    }
    
    func playMedia(at url: URL) {
        let videoPlayerVc = self.viewController(viewControllerClass: VideoPlayerViewController.self, from: StoryBoardIdentifiers.videoPlayer)
        videoPlayerVc.mediaURL = url
        videoPlayerVc.modalPresentationStyle = .fullScreen
        self.present(videoPlayerVc)
    }
    
    func playAudio(_ items: [AVPlayerItem], startIndex: Int, currentIndex: Int,_ URLs: [URL]) {
        
        let audioPlayerVc = self.viewController(viewControllerClass: AudioPlayerViewController.self,
                                                from: StoryBoardIdentifiers.videoPlayer)
        AudioPlayerDataModel.shared.startPlayerItem = items[currentIndex]
        AudioPlayerDataModel.shared.unshuffledQueueItems = items
        AudioPlayerDataModel.shared.queuedItems = items
        AudioPlayerDataModel.shared.itemURLs = URLs
        audioPlayerVc.offlineMode = true
        AudioPlayerDataModel.shared.setupQueueMetadata()
        audioPlayerVc.modalPresentationStyle = .fullScreen
        self.present(audioPlayerVc)
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
}
