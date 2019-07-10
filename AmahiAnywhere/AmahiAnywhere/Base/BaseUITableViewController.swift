//
//  BaseUITableViewController.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 06/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit
import GoogleCast

class BaseUITableViewController: UITableViewController {
    
    private var castButton: GCKUICastButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateNavigationBarBackgroundAccordingToCurrentConnectionMode()
        addActiveDownloadObservers()
        addLanTestObservers()
        
        castButton = GCKUICastButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0),
                                                   width: CGFloat(24), height: CGFloat(24)))
        castButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
}
