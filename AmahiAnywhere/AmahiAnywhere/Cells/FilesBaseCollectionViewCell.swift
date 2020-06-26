//
//  FilesBaseCollectionViewCell.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 19..
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit
import SwipeCellKit

class FilesBaseCollectionCell: SwipeCollectionViewCell{
    override func awakeFromNib() {
        let backgroundView = UIView()
        if #available(iOS 13.0, *) {
            backgroundView.backgroundColor = UIColor.secondarySystemBackground

        } else {
           backgroundView.backgroundColor = UIColor(hex: "1E2023")
        }
        selectedBackgroundView = backgroundView
    }
    
    func setupArtWork(recentFile: Recent, iconImageView: UIImageView){
        let type = recentFile.mimeType
        let url = URL(string: recentFile.fileURL)!
        
        switch type {
        case "image":
            iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "image"), options: .refreshCached)
            break
        case "video":
            if let image = VideoThumbnailGenerator.imageFromMemory(for: url) {
                iconImageView.image = image
            } else {
                iconImageView.image = UIImage(named: "video")
                DispatchQueue.global(qos: .background).async {
                    let image = VideoThumbnailGenerator().getThumbnail(url)
                    DispatchQueue.main.async {
                        iconImageView.image = image
                    }
                }
            }
            break
        case "audio":
            if let image = AudioThumbnailGenerator.imageFromMemory(for: url) {
                iconImageView.image = image
            } else {
                iconImageView.image = UIImage(named: "audio")
                DispatchQueue.global(qos: .background).async {
                    let image = AudioThumbnailGenerator().getThumbnail(url)
                    DispatchQueue.main.async {
                        iconImageView.image = image
                    }
                }
            }
            break
        case "presentation", "document", "spreadsheet":
            if let image = PDFThumbnailGenerator.imageFromMemory(for: url) {
                iconImageView.image = image
            } else {
                iconImageView.image = UIImage(named: "file")
                
                DispatchQueue.global(qos: .background).async {
                    let image = PDFThumbnailGenerator().getThumbnail(url)
                    DispatchQueue.main.async {
                        iconImageView.image = image
                    }
                }
            }
        default:
            iconImageView.image = UIImage(named: "file")
            break
        }
    }
    
    func setupArtWork(serverFile: ServerFile, iconImageView: UIImageView){
        let type = serverFile.mimeType
        
        guard let url = ServerApi.shared!.getFileUri(serverFile) else {
            AmahiLogger.log("Invalid file URL, thumbnail generation failed")
            return
        }
        
        guard let urlThumbnail = ServerApi.shared!.getFileThumbnailUri(serverFile) else {
            AmahiLogger.log("Invalid URL, thumbnail generation failed")
            return
        }
        
        switch type {
        case MimeType.image:
            if ServerApi.shared?.getServer()?.name! == "Welcome to Amahi" {
                iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "image"), options: .refreshCached)
            }
            else {
                iconImageView.sd_setImage(with: urlThumbnail, placeholderImage: UIImage(named: "image"), options: .refreshCached)
            }
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
                iconImageView.image = UIImage(named: "file")
                
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
