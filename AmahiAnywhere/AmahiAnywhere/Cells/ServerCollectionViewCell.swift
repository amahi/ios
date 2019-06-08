//
//  ServerCollectionViewCell.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 05. 30..
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit

class ServerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var serverImageView: UIImageView!
    @IBOutlet weak var serverLabel: UILabel!
    
    func enable(){
        serverImageView.image = UIImage(named: "serverWhite")
        serverLabel.textColor = .white
    }
    
    func disable(){
        serverImageView.image = UIImage(named: "serverGrey")
        serverLabel.textColor = UIColor(hex: "949494")
    }
    
    func isEnabled() -> Bool{
        return serverImageView.image === UIImage(named: "serverWhite")
    }
    
    func setupData(server: Server){
        serverLabel.text = server.name
        server.active ? enable() : disable()
    }
    
    override func awakeFromNib() {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "1E2023")
        selectedBackgroundView = view
    }

}
  
