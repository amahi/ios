//
//  FilesGridCollectionCell.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 17..
//  Copyright © 2019. Amahi. All rights reserved.
//
import UIKit

class FilesGridCollectionCell: FilesBaseCollectionCell {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var downloadIcon: UIImageView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    func setupData(serverFile: ServerFile){
        nameLabel.text = serverFile.name
        if #available(iOS 13.0, *) {
                   nameLabel.textColor = UIColor.label
            downloadIcon.tintColor = UIColor.label
                   moreButton.tintColor = UIColor.label
               } else {
                   nameLabel.textColor = UIColor.white
                   downloadIcon.tintColor = UIColor.white
                   moreButton.tintColor = UIColor.white
               }
        
        if serverFile.isDirectory{
            showDirectory()
        }else{
            showFile()
            setupArtWork(serverFile: serverFile, iconImageView: iconImageView)
        }
    }
    
    func setupData(recentFile: Recent){
        nameLabel.text = recentFile.fileName
        showFile()
        
        setupArtWork(recentFile: recentFile, iconImageView: iconImageView)
    }
    
    func showDirectory(){
        moreButton.isHidden = true
        iconImageView.image = UIImage(named: "folderIcon")
    }
    
    func showFile(){
        moreButton.isHidden = false
    }
}
