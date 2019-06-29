//
//  DownloadsGridCollectionCell.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 27..
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit

class DownloadsGridCollectionCell: DownloadsBaseCollectionCell{
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet weak var brokenIndicatorImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    func setupData(offlineFile: OfflineFile){
        nameLabel.text = offlineFile.name
        
        let image = brokenIndicatorImageView.image
        let templateImage = image?.withRenderingMode(.alwaysTemplate)
        brokenIndicatorImageView.image = templateImage
        brokenIndicatorImageView.tintColor = UIColor.brokenIndicatorRed
        
        progressView.setProgress(offlineFile.progress, animated: false)
        
        if offlineFile.stateEnum == .downloading {
            if let remoteUrl = offlineFile.remoteFileURL() {
                let keyExists = DownloadService.shared.activeDownloads[remoteUrl] != nil
                if !keyExists {
                    offlineFile.stateEnum = .completedWithError
                }
            }
        }
        
        if offlineFile.stateEnum == .completedWithError {
            brokenIndicatorImageView.isHidden = false
        } else {
            brokenIndicatorImageView.isHidden = true
        }
        
        progressView.isHidden = offlineFile.progress == 1.0
        
        setupArtWork(offlineFile: offlineFile, iconImageView: iconImageView)
    }
}
