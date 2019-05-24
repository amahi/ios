//
//  WalkthroughCollectionCell.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 05. 23..
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit

class WalkthroughCollectionCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var descriptionLabel: UILabel!
    
    func setupData(title: String, icon: String, description: String, color: UIColor){
        backgroundColor = color
        titleLabel.text = title
        iconImageView.image = UIImage(named: icon)
        descriptionLabel.text = description
    }
}
