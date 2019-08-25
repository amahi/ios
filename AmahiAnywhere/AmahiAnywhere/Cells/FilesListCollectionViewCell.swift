//
//  FilesListCollectionViewCell.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 17..
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit

class FilesListCollectionViewCell: FilesBaseCollectionCell {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var sizeModifiedLabel: UILabel!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var downloadIcon: UIImageView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    func setupData(serverFile: ServerFile){
        nameLabel.text = serverFile.name
        
        if serverFile.isDirectory{
            showDirectory()
        }else{
            showFile()
            
            let size = serverFile.getFileSize()
            let modified = serverFile.getLastModifiedDate()
            sizeModifiedLabel.text = "\(size), \(modified)"
            
            setupArtWork(serverFile: serverFile, iconImageView: iconImageView)
        }
    }
    
    func setupData(recentFile: Recent){
        nameLabel.text = recentFile.fileName
        showFile()
        
        sizeModifiedLabel.text = "\(recentFile.fileDisplayText), \(recentFile.filesSize)"
        
        setupArtWork(recentFile: recentFile, iconImageView: iconImageView)
    }
    
    func showDirectory(){
        sizeModifiedLabel.isHidden = true
        moreButton.isHidden = true
        iconImageView.image = UIImage(named: "folderIcon")
    }
    
    func showFile(){
        sizeModifiedLabel.isHidden = false
        moreButton.isHidden = false
    }
    
}
