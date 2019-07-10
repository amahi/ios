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
        backgroundView.backgroundColor = UIColor(hex: "1E2023")
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
    
}
