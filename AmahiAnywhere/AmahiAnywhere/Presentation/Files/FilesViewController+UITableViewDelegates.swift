//
//  FilesViewController+UITableViewDelegates.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/17/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

extension FilesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let serverFile = filteredFiles[indexPath.row]
        if serverFile.isDirectory() {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServerDirectoryTableViewCell", for: indexPath)
            cell.textLabel?.text = serverFile.name
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServerFileTableViewCell", for: indexPath) as! ServerFileTableViewCell
            cell.fileNameLabel?.text = serverFile.name
            cell.fileSizeLabel?.text = serverFile.getFileSize()
            cell.lastModifiedLabel?.text = serverFile.getLastModifiedDate()
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(userClickMenu(sender:)))
            tap.cancelsTouchesInView = true
            cell.menuImageView.isUserInteractionEnabled = true
            cell.menuImageView.addGestureRecognizer(tap)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        presenter.handleFileOpening(fileIndex: indexPath.row, files: filteredFiles, from: tableView.cellForRow(at: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let file = self.filteredFiles[indexPath.row]
        let download = UITableViewRowAction(style: .destructive, title: StringLiterals.DOWNLOAD) { (action, indexPath) in
            self.presenter.makeFileAvailableOffline(file)
        }
        download.backgroundColor = UIColor.red
        
        let availableOffline = UITableViewRowAction(style: .destructive, title: StringLiterals.AVAILABLE_OFFLINE) { (action, indexPath) in
        }
        let state = presenter.checkFileOfflineState(file)
        if state  == .downloaded || state == .downloading {
            return [availableOffline]
        }
        
        let share = UITableViewRowAction(style: .normal, title: StringLiterals.SHARE) { (action, indexPath) in
        }
        share.backgroundColor = UIColor.blue
        
        return [download]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let file = self.filteredFiles[indexPath.row]
        if file.isDirectory() {
            return false
        }
        return true
    }
}
