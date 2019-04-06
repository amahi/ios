//
//  OfflineFileTableViewCell.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/17/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import AVFoundation

class OfflineFileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var downloadDateLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var brokenIndicatorImageView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    public var offlineFile: OfflineFile? {
        didSet {
            guard let offlineFile = offlineFile else {
                return
            }
            
            fileNameLabel?.text = offlineFile.name
            fileSizeLabel?.text = offlineFile.getFileSize()
            downloadDateLabel?.text = offlineFile.downloadDate?.asString
            
            let image = brokenIndicatorImageView.image
            let templateImage = image?.withRenderingMode(.alwaysTemplate)
            brokenIndicatorImageView.image = templateImage
            brokenIndicatorImageView.tintColor = UIColor.brokenIndicatorRed
            
            setupArtWork()
        }
    }
    
    private func setupArtWork() {
        guard let offlineFile = offlineFile else {
            return
        }
        
        let fileManager = FileManager.default
        
        if !fileManager.fileExistsInDownloads(offlineFile) {
            AmahiLogger.log("OFFLINE FILE DOES NOT EXIST IN EXPECTED LOCATION !!!")
            return
        }
        
        let url = fileManager.localFilePathInDownloads(for: offlineFile)!
        
        let type = Mimes.shared.match(offlineFile.mime!)
        
        switch type {
            
        case MimeType.image:
            thumbnailImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "image"), options: .refreshCached)
            break
            
        case MimeType.video:
            
            if let image = VideoThumbnailGenerator.imageFromMemory(for: url) {
                thumbnailImageView.image = image
            } else {
                thumbnailImageView.image = UIImage(named: "video")
                DispatchQueue.global(qos: .background).async {
                    let image = VideoThumbnailGenerator().getThumbnail(url)
                    DispatchQueue.main.async {
                        // Code to be executed on the main thread here
                        self.thumbnailImageView.image = image
                    }
                }
            }
            break
            
        case MimeType.audio:
            
            if let image = AudioThumbnailGenerator.imageFromMemory(for: url) {
                thumbnailImageView.image = image
            } else {
                thumbnailImageView.image = UIImage(named: "audio")
                DispatchQueue.global(qos: .background).async {
                    let image = AudioThumbnailGenerator().getThumbnail(url)
                    DispatchQueue.main.async {
                        // Code to be executed on the main thread here
                        self.thumbnailImageView.image = image
                    }
                }
            }
            break
            
        case MimeType.presentation, MimeType.document, MimeType.spreadsheet:
            
            if let image = PDFThumbnailGenerator.imageFromMemory(for: url) {
                thumbnailImageView.image = image
            } else {
                DispatchQueue.global(qos: .background).async {
                    let image = PDFThumbnailGenerator().getThumbnail(url)
                    DispatchQueue.main.async {
                        // Code to be executed on the main thread here
                        self.thumbnailImageView.image = image
                    }
                }
            }
            
        default:
            thumbnailImageView.image = UIImage(named: "file")
            break
        }
    }
}
