//
//  ServerFileTableViewswift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/17/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit

class ServerFileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var lastModifiedLabel: UILabel!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    public var serverFile: ServerFile? {
        didSet {
            guard let serverFile = serverFile else {
                return
            }
            
            fileNameLabel?.text = serverFile.name
            fileSizeLabel?.text = serverFile.getFileSize()
            lastModifiedLabel?.text = serverFile.getLastModifiedDate()
            
            setupArtWork()
        }
    }
    
    private func setupArtWork() {
        guard let serverFile = serverFile else {
            return
        }

        let type = Mimes.shared.match(serverFile.mime_type!)
        
        guard let url = ServerApi.shared!.getFileUri(serverFile) else {
            AmahiLogger.log("Invalid file URL, thumbnail generation failed")
            return
        }
        
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
                thumbnailImageView.image = UIImage(named: "file")

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
