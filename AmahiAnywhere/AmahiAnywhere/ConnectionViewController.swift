//
//  ConnectionViewController.swift
//  AmahiAnywhere
//
//  Created by Syed on 28/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit

class ConnectionViewController: UITableViewController {
    
    var connectionItem = [String]()
    var selectedItemIndex: Int?
    var selectedItem: String? {
        didSet {
            if let selectedItem = selectedItem,
                let index = connectionItem.index(of: selectedItem) {
                selectedItemIndex = index
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        connectionItem = ["Autodetect","LAN","Remote"]
            }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return connectionItem.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = selectedItemIndex {
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
            cell?.accessoryType = .none
        }
        
        selectedItem = connectionItem[indexPath.row]
        
        // update the checkmark for the current row
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
                tableView.deselectRow(at: indexPath, animated: true)
            }
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: StringLiterals.CONNECTION_CELL_IDENTIFIER, for: indexPath)
        
                cell.textLabel?.text = connectionItem[indexPath.row]
                cell.textLabel?.textColor = UIColor.white
            if indexPath.row == selectedItemIndex {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
}
}
