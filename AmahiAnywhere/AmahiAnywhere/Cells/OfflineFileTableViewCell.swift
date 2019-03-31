//
//  OfflineFileTableViewCell.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/17/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

class OfflineFileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var downloadDateLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var brokenIndicatorImageView: UIImageView!
    @IBOutlet weak var thumbnailImage: UIImageView!
}
