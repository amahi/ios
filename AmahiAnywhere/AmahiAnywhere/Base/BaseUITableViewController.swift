//
//  BaseUITableViewController.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 06/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit

class BaseUITableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove Back Button Text
        navigationItem.title = ""
    }
}
