//
//  QueueContainerHeaderView.swift
//  AmahiAnywhere
//
//  Created by Shresth Pratap Singh on 15/06/20.
//  Copyright © 2020 Amahi. All rights reserved.
//

import UIKit

protocol QueueHeaderTapDelegate {
    func didTapOnQueueHeader()
}

class QueueContainerHeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
        updateBackgroundColor()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tapDelegate: QueueHeaderTapDelegate?
    
    lazy var upNextLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .white
        }
        label.text = "Up next"
        return label
    }()
    
    lazy var blurEffect:UIVisualEffectView={
        let effectsView = UIVisualEffectView()
        if #available(iOS 13.0, *) {
            effectsView.effect = UIBlurEffect(style: .systemThinMaterial)
        } else {
            effectsView.effect = UIBlurEffect(style: .dark)
        }
        effectsView.alpha = 1
        return effectsView
    }()
    
    lazy var arrowHead:UIButton = {
        let button = UIButton(type:.system)
        button.setImage(UIImage(named:"arrowDownIcon"), for: .normal)
        button.showsTouchWhenHighlighted = true
        button.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        return button
    }()
    
    var colorSchemes = ["#4B878B","#755139","#D7A9E3","#a32243"]
    var colorIndex = 0
    
    func updateBackgroundColor(){
        UIView.animate(withDuration: 0.7) {
            let index = self.colorIndex % (self.colorSchemes.count-1)
            self.colorIndex += 1
            self.backgroundColor = UIColor(hex: self.colorSchemes[index])
        }
    }
    
    private func layout(){
        
        blurEffect.contentView.addSubview(upNextLabel)
        blurEffect.contentView.addSubview(arrowHead)
        self.addSubview(blurEffect)
        
        upNextLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowHead.translatesAutoresizingMaskIntoConstraints = false
        blurEffect.translatesAutoresizingMaskIntoConstraints = false
        
        blurEffect.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        blurEffect.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        blurEffect.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        blurEffect.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true

        
        upNextLabel.topAnchor.constraint(equalTo: blurEffect.topAnchor, constant: 0).isActive = true
        upNextLabel.leadingAnchor.constraint(equalTo: blurEffect.leadingAnchor, constant: 20).isActive = true
        upNextLabel.trailingAnchor.constraint(equalTo: arrowHead.leadingAnchor, constant: -10).isActive = true
        upNextLabel.bottomAnchor.constraint(equalTo: blurEffect.bottomAnchor, constant: 0).isActive = true
        
        arrowHead.centerYAnchor.constraint(equalTo: upNextLabel.centerYAnchor, constant: 0).isActive = true
        arrowHead.heightAnchor.constraint(equalToConstant: 45).isActive = true
        arrowHead.widthAnchor.constraint(equalTo: arrowHead.heightAnchor).isActive = true
        arrowHead.leadingAnchor.constraint(equalTo: upNextLabel.trailingAnchor, constant: 10).isActive = true
        arrowHead.trailingAnchor.constraint(equalTo: blurEffect.trailingAnchor, constant: -15).isActive = true
        arrowHead.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)
    }
    
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer){
        tapDelegate?.didTapOnQueueHeader()
    }
    
}
