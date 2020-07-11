//
//  UIColor.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 3/18/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit.UIColor

extension UIColor {
    
    convenience init(hex string: String) {
        var hex = string.hasPrefix("#")
            ? String(string.dropFirst())
            : string
        guard hex.count == 3 || hex.count == 6
            else {
                self.init(white: 1.0, alpha: 0.0)
                return
        }
        if hex.count == 3 {
            for (index, char) in hex.enumerated() {
                hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
            }
        }
        
        self.init(
            red:   CGFloat((Int(hex, radix: 16)! >> 16) & 0xFF) / 255.0,
            green: CGFloat((Int(hex, radix: 16)! >> 8) & 0xFF) / 255.0,
            blue:  CGFloat((Int(hex, radix: 16)!) & 0xFF) / 255.0, alpha: 1.0)
    }
    
    class var softYellow: UIColor {
        return UIColor(red: 0.81, green: 0.85, blue: 0.26, alpha: 0.7)
    }
    
    class var remoteIndicatorBrown: UIColor {
        return UIColor(red: 152 / 255.0, green: 38 / 255.0, blue: 73 / 255.0, alpha: 1)
    }
    
    class var localIndicatorBlack: UIColor {
        return UIColor(red: 28 / 255.0, green: 28 / 255.0, blue: 31 / 255.0, alpha: 1)
    }
    
    class var brokenIndicatorRed : UIColor {
        return UIColor(red: 211 / 255.0, green: 33 / 255.0, blue: 45 / 255.0, alpha: 1)
    }
}
