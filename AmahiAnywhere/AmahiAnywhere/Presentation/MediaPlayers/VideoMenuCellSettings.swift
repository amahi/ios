//
//  VideoMenuCellSettings.swift
//  AmahiAnywhere
//
//  Created by Abhishek Sansanwal on 30/05/19.
//  Copyright © 2019 Amahi. All rights reserved.
//

import UIKit

class VideoMenuCellSettings: UICollectionViewCell {
    
    override var isHighlighted: Bool {
        didSet {
           backgroundColor = isHighlighted ? UIColor.darkGray : UIColor(red:28/255, green:28/255, blue:27/255, alpha:1)
        }
    }
    
    var option: Options? {
        didSet {
            optionName.text = option?.name
            if let imageName = option?.imageName {
                iconImageView.image = UIImage(named:imageName)
            }
        }
    }
    
    let optionName: UILabel = {
        let label = UILabel()
        label.text = "Setting"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.white
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"AppIcon")
        imageView.contentMode = ContentMode.scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        addSubview(optionName)
        addSubview(iconImageView)
        
        addConstraintsWithFormat(format: "H:|-8-[v0(20)]-15-[v1]|", views: iconImageView,optionName)
        addConstraintsWithFormat(format: "V:|[v0]|", views: optionName)
          addConstraintsWithFormat(format: "V:[v0(20)]", views: iconImageView)
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for(index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
