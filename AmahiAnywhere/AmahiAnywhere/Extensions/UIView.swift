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
    
    // Anchors
    
    func setAnchors(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, trailing: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, topConstant: CGFloat?, leadingConstant: CGFloat?, trailingConstant: CGFloat?, bottomConstant: CGFloat?){
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top, let topConstant = topConstant{
            topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
        }
        
        if let leading = leading, let leadingConstant = leadingConstant{
            leadingAnchor.constraint(equalTo: leading, constant: leadingConstant).isActive = true
        }
        
        if let trailing = trailing, let trailingConstant = trailingConstant{
            trailingAnchor.constraint(equalTo: trailing, constant: -trailingConstant).isActive = true
        }
        
        if let bottom = bottom, let bottomConstant = bottomConstant{
            bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant).isActive = true
        }
    }
    
    func setAnchorSize(width: CGFloat?, height: CGFloat?){
        translatesAutoresizingMaskIntoConstraints = false
        if let width = width{
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height{
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func setAnchorSize(to view: UIView, widthMultiplier: CGFloat?, heightMultiplier: CGFloat?)
        
    {
        translatesAutoresizingMaskIntoConstraints = false
        if let widthMultiplier = widthMultiplier{
            widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: widthMultiplier).isActive = true
        }
        
        if let heightMultiplier = heightMultiplier{
            heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: heightMultiplier).isActive = true
        }
    }
    
    func fillSuperView(){
        translatesAutoresizingMaskIntoConstraints = false
        setAnchors(top: superview?.topAnchor, leading: superview?.leadingAnchor, trailing: superview?.trailingAnchor, bottom: superview?.bottomAnchor, topConstant: 0, leadingConstant: 0, trailingConstant: 0, bottomConstant: 0)
    }
    
    func center(toVertically: UIView?, toHorizontally: UIView?){
        translatesAutoresizingMaskIntoConstraints = false
        
        if let toVertically = toVertically{
            centerYAnchor.constraint(equalTo: toVertically.centerYAnchor).isActive = true
        }
        
        if let toHorizontally = toHorizontally{
            centerXAnchor.constraint(equalTo: toHorizontally.centerXAnchor).isActive = true
        }
    }
    
    func centerWithConstant(toVertically: UIView?, toHorizontally: UIView?, verticalConstant: CGFloat?, horizontatlConstant: CGFloat?){
        translatesAutoresizingMaskIntoConstraints = false
        
        if let toVertically = toVertically, let verticalConstant = verticalConstant{
            centerYAnchor.constraint(equalTo: toVertically.centerYAnchor, constant: verticalConstant).isActive = true
        }
        
        if let toHorizontally = toHorizontally, let horizontatlConstant = horizontatlConstant{
            centerXAnchor.constraint(equalTo: toHorizontally.centerXAnchor, constant: horizontatlConstant).isActive = true
        }
    }
    
}
