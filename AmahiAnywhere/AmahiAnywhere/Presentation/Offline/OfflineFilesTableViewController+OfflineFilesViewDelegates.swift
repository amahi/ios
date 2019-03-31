//
//  OfflineFilesTableViewController+OfflineFilesViewDelegates.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/18/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import AVKit
import Foundation
import MediaPlayer

extension OfflineFilesTableViewController : OfflineFilesView {
    
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
        self.present(videoPlayerVc)
    }
    
    func playAudio(_ items: [AVPlayerItem], startIndex: Int) {
        
        let avPlayerVC = AVPlayerViewController()
        player = AVQueuePlayer(items: items)
        player.actionAtItemEnd = .advance
        avPlayerVC.player = player
        
        for item in items {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(FilesViewController.nextAudio(notification:)),
                                                   name: .AVPlayerItemDidPlayToEndTime, object: item)
        }
        
        present(avPlayerVC, animated: true) {
            self.player.play()
        }
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
