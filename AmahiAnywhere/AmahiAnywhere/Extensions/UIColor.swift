//
//  UIColor.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 3/18/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

extension UIColor {
    
    class var softYellow: UIColor {
        get {
            return UIColor(red:0.81, green:0.85, blue:0.26, alpha:0.7)
        }
    }
    
    class var remoteIndicatorBrown: UIColor {
        get {
            return UIColor(red:152/255, green:38/255, blue:73/255, alpha:1)
        }
    }
    
    class var localIndicatorBlack: UIColor {
        get {
            return UIColor(red:28/255, green:28/255, blue:31/255, alpha:1)
        }
    }
    
    class var brokenIndicatorRed : UIColor {
        get {
            return UIColor(red:211/255, green:33/255, blue:45/255, alpha:1)
        }
    }
}
