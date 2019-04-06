//
//  FilesViewController+UITableViewDelegates.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/17/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation
import SDWebImage
import Lightbox
import AVFoundation

extension FilesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configuring Lightbox to use SDWebImage for caching images
        LightboxConfig.loadImage = {
            imageView, URL, completion in
            imageView.sd_setImage(with: URL, placeholderImage: nil, options: .refreshCached, completed: { (image, data, error, true) in
                completion?(nil)
            })
        }
        
        let serverFile = filteredFiles[indexPath.row]
        if serverFile.isDirectory() {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServerDirectoryTableViewCell", for: indexPath)
            cell.textLabel?.text = serverFile.name
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServerFileTableViewCell", for: indexPath) as! ServerFileTableViewCell
            
            cell.serverFile = serverFile
            
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
        let download = UITableViewRowAction(style: .destructive, title: StringLiterals.download) { (action, indexPath) in
            self.presenter.makeFileAvailableOffline(file)
        }
        download.backgroundColor = UIColor.red
        
        let availableOffline = UITableViewRowAction(style: .destructive, title: StringLiterals.availableOffline) { (action, indexPath) in
        }
        let state = presenter.checkFileOfflineState(file)
        if state  == .downloaded || state == .downloading {
            return [availableOffline]
        }
        
        let share = UITableViewRowAction(style: .normal, title: StringLiterals.share) { (action, indexPath) in
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
