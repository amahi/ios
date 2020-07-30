//
//  AudioThumbnailCollectionCell.swift
//  AmahiAnywhere
//
//  Created by Shresth Pratap Singh on 14/07/20.
//  Copyright © 2020 Amahi. All rights reserved.
//

import UIKit

class AudioThumbnailCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView.layer.masksToBounds = false
        self.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = UIScreen.main.bounds.width * 0.04
    }
        
    override func prepareForReuse() {
        imageView.image = UIImage(named: "musicPlayerArtWork")
    }

}
