//
//  SettingsViewController+TableViewDataSource.swift
//  AmahiAnywhere
//
//  Created by Kanyinsola Fapohunda on 03/04/2019.
//  Copyright © 2019 Amahi. All rights reserved.
//

import Foundation

extension SettingsViewController {
    
    // MARK: - Table View data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return titleForSections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForSections[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return settingItems[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        
        var cell: UITableViewCell
        
        if section == 1 || (section == 2 && row == 0) {
            
            cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.settingsCellWithDetails, for: indexPath)
            cell.textLabel?.text = settingItems[section][row]
            cell.textLabel?.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.lightGray
            
            if section == 1 && row == 0 {
                let connectionMode = LocalStorage.shared.userConnectionPreference
                
                if connectionMode == ConnectionMode.auto {
                    let isLocalInUse = ConnectionModeManager.shared.isLocalInUse()
                    
                    if isLocalInUse {
                        cell.detailTextLabel?.text =  StringLiterals.autoConnectLAN
                    } else {
                        cell.detailTextLabel?.text =  StringLiterals.autoConnectRemote
                    }
                } else {
                    cell.detailTextLabel?.text =  LocalStorage.shared.userConnectionPreference.rawValue
                }
            }
            else if section == 1 && row == 1 {
                
                let cacheFolderPath = FileManager.default.temporaryDirectory.appendingPathComponent("cache").path
                
                let cacheSize = FileManager.default.folderSizeAtPath(path: cacheFolderPath)
                cell.detailTextLabel?.text = String(format: StringLiterals.currentSize, ByteCountFormatter().string(fromByteCount: cacheSize))
            }
            else if section == 2 && row == 0 {
                if let versionNumber = Bundle.main.object(forInfoDictionaryKey: StringLiterals.versionNumberDictionaryKey) as! String? {
                    cell.detailTextLabel?.text = "v\(versionNumber)"
                }
            }
        } else {
            
            cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.settingsCell, for: indexPath)
            cell.textLabel?.text = settingItems[section][row]
            cell.textLabel?.textColor = UIColor.white
        }
        
        return cell
    }
}
