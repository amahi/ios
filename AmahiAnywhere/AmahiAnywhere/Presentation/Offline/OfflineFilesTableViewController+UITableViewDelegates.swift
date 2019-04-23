//
//  OfflineFilesTableViewController+UITableViewDelegates.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/17/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation
import SDWebImage

extension OfflineFilesTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let offlineFile = fetchedResultsController!.object(at: indexPath) as! OfflineFile
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OfflineFileTableViewCell", for: indexPath) as! OfflineFileTableViewCell
        cell.offlineFile = offlineFile
        
        cell.progressView.setProgress(offlineFile.progress, animated: false)

        let tap = UITapGestureRecognizer(target: self, action: #selector(userClickMenu(sender:)))
        tap.cancelsTouchesInView = true
        cell.menuImageView.isUserInteractionEnabled = true
        cell.menuImageView.addGestureRecognizer(tap)
        
        if offlineFile.stateEnum != .downloading {
            cell.progressView.isHidden = true
        } else {
            if let remoteUrl = offlineFile.remoteFileURL() {
                let keyExists = DownloadService.shared.activeDownloads[remoteUrl] != nil
                if !keyExists {
                    offlineFile.stateEnum = .completedWithError
                }
            }
        }
        
        if offlineFile.stateEnum == .completedWithError {
            cell.brokenIndicatorImageView.isHidden = false
            cell.fileSizeLabel.isHidden = true
        } else {
            cell.brokenIndicatorImageView.isHidden = true
            cell.fileSizeLabel.isHidden = false
        }
        
        AmahiLogger.log("Offline File State at index: \(indexPath.row) \(offlineFile.stateEnum) with progress \(offlineFile.progress)")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let offlineFile = self.fetchedResultsController!.object(at: indexPath) as! OfflineFile
        
        let delete = UITableViewRowAction(style: .destructive, title: StringLiterals.delete) { (action, indexPath) in
            
            // Delete file in downloads directory
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: fileManager.localFilePathInDownloads(for: offlineFile)!)
            } catch let error {
                AmahiLogger.log("Couldn't Delete file from Downloads \(error.localizedDescription)")
            }
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let stack = delegate.stack
            
            // Delete Offline File from CoreData and persist new changes immediately
            stack.context.delete(offlineFile)
            try? stack.saveContext()
            AmahiLogger.log("File was deleted from Downloads")
        }
        delete.backgroundColor = UIColor.red
        
        let share = UITableViewRowAction(style: .normal, title: StringLiterals.share) { (action, indexPath) in
            
            guard let url = FileManager.default.localFilePathInDownloads(for: offlineFile) else { return }
            self.shareFile(at: url, from: tableView.cellForRow(at: indexPath))
        }
        share.backgroundColor = UIColor.blue
        
        var actions = [UITableViewRowAction]()
        if offlineFile.stateEnum == .downloaded {
            actions.append(share)
        }
        actions.append(delete)
        return actions
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        for file in fetchedResultsController!.fetchedObjects! {
            if (file as! OfflineFile).stateEnum == .downloading {
                return false
            }
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let offlineFiles : [OfflineFile] = fetchedResultsController?.fetchedObjects as! [OfflineFile]
        if offlineFiles[indexPath.row].stateEnum == .downloaded {
            presenter.handleOfflineFile(fileIndex: indexPath.row, files: offlineFiles, from: tableView.cellForRow(at: indexPath))
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
