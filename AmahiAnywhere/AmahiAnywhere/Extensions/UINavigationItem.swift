//
//  UINavigationItem.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 08. 17..
//  Copyright © 2019. Amahi. All rights reserved.
//

import Foundation

extension UINavigationItem{
    func setTitleWithRemoteIcon(title:String) {
        
        let one = UILabel()
        one.text = title
        if #available(iOS 13.0, *) {
            one.textColor = .label
        } else {
            one.textColor = .white
        }
        one.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        one.sizeToFit()
        
        let imageView = UIImageView(image: UIImage(named: "remoteIcon"))
        imageView.contentMode = .scaleAspectFit
        imageView.sizeToFit()
        
        let stackView = UIStackView(arrangedSubviews: [one, imageView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = 8
        
        let width = max(one.frame.size.width, imageView.frame.size.width)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: 35)
        
        one.sizeToFit()
        imageView.sizeToFit()
        
        self.titleView = stackView
    }
}
