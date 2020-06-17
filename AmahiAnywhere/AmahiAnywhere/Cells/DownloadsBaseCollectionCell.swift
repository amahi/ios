//
//  DownloadsBaseCollectionCell.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 27..
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit
import SwipeCellKit

class DownloadsBaseCollectionCell: SwipeCollectionViewCell{
    
    override func awakeFromNib() {
        let backgroundView = UIView()
        if #available(iOS 13.0, *) {

            backgroundView.backgroundColor = UIColor.secondarySystemBackground

        } else {
            backgroundView.backgroundColor = UIColor(hex: "1E2023")
        }
        selectedBackgroundView = backgroundView
    }
    
    func setupArtWork(offlineFile: OfflineFile, iconImageView: UIImageView){
        let fileManager = FileManager.default
        let url = fileManager.localFilePathInDownloads(for: offlineFile)!
        let type = offlineFile.mimeType
        
        switch type {
        case .image:
            iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "image"), options: .refreshCached)
            break
        case .video:
            if let image = VideoThumbnailGenerator.imageFromMemory(for: url) {
                iconImageView.image = image
            } else {
                iconImageView.image = UIImage(named: "video")
                DispatchQueue.global(qos: .background).async {
                    let image = VideoThumbnailGenerator().getThumbnail(url)
                    DispatchQueue.main.async {
                        // Code to be executed on the main thread here
                        iconImageView.image = image
                    }
                }
            }
            break
        case .audio:
            if let image = AudioThumbnailGenerator.imageFromMemory(for: url) {
                iconImageView.image = image
            } else {
                iconImageView.image = UIImage(named: "audio")
                DispatchQueue.global(qos: .background).async {
                    let image = AudioThumbnailGenerator().getThumbnail(url)
                    DispatchQueue.main.async {
                        // Code to be executed on the main thread here
                        iconImageView.image = image
                    }
                }
            }
            break
        case .presentation, .document, .spreadsheet:
            if let image = PDFThumbnailGenerator.imageFromMemory(for: url) {
                iconImageView.image = image
            } else {
                DispatchQueue.global(qos: .background).async {
                    let image = PDFThumbnailGenerator().getThumbnail(url)
                    DispatchQueue.main.async {
                        // Code to be executed on the main thread here
                        iconImageView.image = image
                    }
                }
            }
        default:
            iconImageView.image = UIImage(named: "file")
            break
        }
    }
    
    
    func updateProgress(offlineFile: OfflineFile, progressView: UIProgressView, brokenIndicator: UIImageView, iconImageView: UIImageView){
        setupProgressView(offlineFile: offlineFile, progressView: progressView)
        
        if offlineFile.stateEnum == .downloading {
            if let remoteUrl = offlineFile.remoteFileURL() {
                let keyExists = DownloadService.shared.activeDownloads[remoteUrl] != nil
                if !keyExists {
                    offlineFile.stateEnum = .completedWithError
                }
            }
        }
        
        if offlineFile.stateEnum == .completedWithError {
            brokenIndicator.isHidden = false
        } else {
            brokenIndicator.isHidden = true
        }
        
        if offlineFile.progress == 1.0{
            setupArtWork(offlineFile: offlineFile, iconImageView: iconImageView)
        }
    }
    
    func setupProgressView(offlineFile: OfflineFile, progressView: UIProgressView){
        progressView.isHidden = offlineFile.progress == 1.0
        if progressView.progress == 1.0 && offlineFile.progress != 0{
            progressView.setProgress(offlineFile.progress, animated: false)
        }else{
            progressView.setProgress(offlineFile.progress, animated: false)
        }
    }
    
    
}
