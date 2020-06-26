//
//  SortViewTableViewCell.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 19..
//  Copyright © 2019. Amahi. All rights reserved.
//
import UIKit

class SortViewTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let label: UILabel = {
        let label = UILabel()
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .white
        }
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    func setupViews(){
        backgroundColor = .clear
        let backgroundView = UIView()
        if #available(iOS 13.0, *) {

            backgroundView.backgroundColor = UIColor.secondarySystemBackground

        } else {
           backgroundView.backgroundColor = UIColor(hex: "1E2023")
        }
        selectedBackgroundView = backgroundView
        addSubview(iconImageView)
        addSubview(label)
        
        iconImageView.setAnchors(top: nil, leading: safeAreaLayoutGuide.leadingAnchor, trailing: nil, bottom: nil, topConstant: nil, leadingConstant: 20, trailingConstant: nil, bottomConstant: nil)
        iconImageView.center(toVertically: self, toHorizontally: nil)
        iconImageView.setAnchorSize(width: 20, height: 20)
        
        label.setAnchors(top: nil, leading: iconImageView.trailingAnchor, trailing: nil, bottom: nil, topConstant: nil, leadingConstant: 20, trailingConstant: nil, bottomConstant: nil)
        label.center(toVertically: iconImageView, toHorizontally: nil)
    }
    
    func setData(imageName: String, text: String){
        iconImageView.image = UIImage(named: imageName)
        label.text = text
    }
}
