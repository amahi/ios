//
//  OfflineFilesTableViewController.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/15/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class OfflineFilesTableViewController : CoreDataTableViewController {
    
    internal var fileSort = OfflineFileSort.dateAdded
    internal var docController: UIDocumentInteractionController?
    @objc internal var player: AVPlayer!
    
    internal var presenter: OfflineFilesPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        AmahiLogger.log("Active Downloads \(DownloadService.shared.activeDownloads)")
        presenter = OfflineFilesPresenter(self)

        self.navigationItem.title = StringLiterals.offline
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPressGesture)
        
        // Setup Core Data for TableView
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OfflineFile")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "downloadDate", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    @objc func handleLongPress(sender: UIGestureRecognizer) {
    
        if tableView.isEditing {
            return
        }
        
        let touchPoint = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touchPoint) {

            let offlineFile = self.fetchedResultsController!.object(at: indexPath) as! OfflineFile

            let delete = self.creatAlertAction(StringLiterals.delete, style: .default) { (action) in
                if offlineFile.stateEnum != .downloading {
                    DownloadService.shared.cancelDownload(offlineFile)
                }
                self.delete(file: offlineFile)
            }!
            
            let open = self.creatAlertAction(StringLiterals.open, style: .default) { (action) in
                let offlineFiles : [OfflineFile] = self.fetchedResultsController?.fetchedObjects as! [OfflineFile]
                self.presenter.handleOfflineFile(fileIndex: indexPath.row, files: offlineFiles, from: self.tableView.cellForRow(at: indexPath))
            }!
            
            let share = self.creatAlertAction(StringLiterals.share, style: .default) { (action) in
                guard let url = FileManager.default.localFilePathInDownloads(for: offlineFile) else { return }
                self.shareFile(at: url, from: self.tableView.cellForRow(at: indexPath))
            }!
            
            let stop = self.creatAlertAction(StringLiterals.stopDownload, style: .default) { (action) in
                DownloadService.shared.cancelDownload(offlineFile)
                self.delete(file: offlineFile)
            }!
            
            var actions = [UIAlertAction]()
            
            let state = offlineFile.stateEnum
            if state == .downloaded {
                if Mimes.shared.match(offlineFile.mime!) != .sharedFile {
                    actions.append(open)
                }
                actions.append(delete)
                actions.append(share)
            } else if state == .completedWithError {
                actions.append(delete)
            } else if state == .downloading {
                actions.append(stop)
                actions.append(delete)
            }
            
            let cancel = self.creatAlertAction(StringLiterals.cancel, style: .cancel, clicked: nil)!
            actions.append(cancel)
            
            self.createActionSheet(title: "",
                                   message: StringLiterals.chooseOne,
                                   ltrActions: actions,
                                   preferredActionPosition: 0,
                                   sender: tableView.cellForRow(at: indexPath))
            }
    }
    
    @objc func userClickMenu(sender: UIGestureRecognizer) {
        handleLongPress(sender: sender)
    }
    
    private func delete(file offlineFile: OfflineFile) {
        // Delete file in downloads directory
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: fileManager.localFilePathInDownloads(for: offlineFile)!)
        } catch let error {
            AmahiLogger.log("Couldn't Delete file from Downloads \(error.localizedDescription)")
        }
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        // Delete Offline File from core date and persist new changes immediately
        stack.context.delete(offlineFile)
        try? stack.saveContext()
        AmahiLogger.log("File was deleted from Downloads")
    }
}
