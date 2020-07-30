//
//  UIImageExtension.swift
//  AmahiAnywhere
//
//  Created by Shresth Pratap Singh on 30/07/20.
//  Copyright © 2020 Amahi. All rights reserved.
//

import Foundation

extension UIImage {

/**
 - Parameter cornerRadius: The radius to round the image to.
 - Returns: A new image with the specified `cornerRadius`.
 **/
func roundedImage(cornerRadius: CGFloat) -> UIImage? {
    let size = self.size

    // create image layer
    let imageLayer = CALayer()
    imageLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    imageLayer.contents = self.cgImage

    // set radius
    imageLayer.masksToBounds = true
    imageLayer.cornerRadius = cornerRadius

    // get rounded image
    UIGraphicsBeginImageContext(size)
    if let context = UIGraphicsGetCurrentContext() {
        imageLayer.render(in: context)
    }
    let roundImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return roundImage
    }
}

