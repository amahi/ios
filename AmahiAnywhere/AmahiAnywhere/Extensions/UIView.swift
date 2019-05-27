//
//  UIView.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 05. 25..
//  Copyright © 2019. Amahi. All rights reserved.
//

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
}
