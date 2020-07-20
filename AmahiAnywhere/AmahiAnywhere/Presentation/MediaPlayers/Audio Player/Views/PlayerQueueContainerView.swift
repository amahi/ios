//
//  PlayerQueueContainerView.swift
//  AmahiAnywhere
//
//  Created by Shresth Pratap Singh on 15/06/20.
//  Copyright © 2020 Amahi. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerQueueContainerView: UIView {
    
    let header = QueueContainerHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 65))
    var queueVC = AudioPlayerQueueViewController()

    
    init(target:UIViewController) {
        super.init(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.7))
        
        configure(target)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func layout(){
        addSubview(header)
        bringSubviewToFront(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        queueVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        queueVC.view.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 0).isActive = true
        queueVC.view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        queueVC.view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        queueVC.view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        header.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        header.heightAnchor.constraint(equalToConstant: 65).isActive = true
        
    }
    
    private func configure(_ target: UIViewController){
        if let audioPlayerVC = target as? AudioPlayerViewController{
            queueVC.delegate = audioPlayerVC
            queueVC.willMove(toParent: audioPlayerVC)
            addSubview(queueVC.view)
            audioPlayerVC.addChild(queueVC)
            queueVC.didMove(toParent: audioPlayerVC)

            layout()
        }
    }
}
