//
//  SharesCollectionViewCell.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 07. 18..
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit

class SharesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        let view = UIView()
        view.layer.cornerRadius = 8
    
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.secondarySystemBackground

            titleLabel.textColor = UIColor.label
        } else {
            view.backgroundColor = UIColor(hex: "1E2023")
            titleLabel.textColor = UIColor.white

        }
        
        selectedBackgroundView = view
    }
    
}
