//
//  WalkthroughAmahiCollectionViewCell.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 05. 23..
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit

class WalkthroughAmahiCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var greyView: UIView!
    
    override func awakeFromNib() {
        greyView.layer.cornerRadius = 8
    }
    
}
