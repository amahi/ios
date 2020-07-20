//
//  QueueItemTableViewCell.swift
//  AmahiAnywhere
//
//  Created by Shresth Pratap Singh on 29/06/20.
//  Copyright © 2020 Amahi. All rights reserved.
//

import UIKit

class QueueItemTableViewCell:UITableViewCell{
    
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    override func prepareForReuse() {
        thumbnailView.image = UIImage(named:"musicPlayerArtWork")
        titleLabel.text = "Title"
        artistLabel.text = "Artist"
    }
}
