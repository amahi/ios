//
//  SettingsViewController+TableViewDelegate.swift
//  AmahiAnywhere
//
//  Created by Kanyinsola Fapohunda on 03/04/2019.
//  Copyright © 2019 Amahi. All rights reserved.
//

import Foundation

extension SettingsViewController {

// MARK: - Table View data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
            
        case 0:
            handleSignOut()
            break
        case 1:
            if row == 0 {
                performSegue(withIdentifier: SegueIdentfiers.connection, sender: nil)
            } else if row == 1 {
                let cacheFolderPath = FileManager.default.temporaryDirectory.appendingPathComponent("cache").path
                let cacheSize = FileManager.default.folderSizeAtPath(path: cacheFolderPath)
                if cacheSize == 0{
                    // Cache is empty already
                    self.showStatusAlert(title: "Temporary downloads folder is empty")
                }else{
                    performCacheInvalidation()
                }
            }
            
            break
        case 2:
            if row == 1 {
                handleShareByEmail()
            }
            break
        default:
            break
        }
    }
}
