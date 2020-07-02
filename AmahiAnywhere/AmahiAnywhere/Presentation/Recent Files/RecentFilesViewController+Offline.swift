//
//  RecentFilesViewController+Offline.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 08. 25..
//  Copyright © 2019. Amahi. All rights reserved.
//

import CoreData

extension RecentFilesViewController{
    
    @objc func offlineFileUpdated(_ notification: Notification){
        
        if notification.userInfo?["loadOfflineFiles"] != nil{
            // If offline files have changed - an offline file was deleted
            loadOfflineFiles()
        }
        
        if let offlineFile = notification.object as? OfflineFile, let indexPath = OfflineFileIndexesRecents.offlineFilesIndexPaths[offlineFile] {
            if indexPath.item < filteredRecentFiles.count{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    UIView.performWithoutAnimation {
                        self.filesCollectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        }
    }
    
    func makeFileAvailableOffline(_ recentFile: Recent, indexPath: IndexPath){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        var path = recentFile.path.replacingOccurrences(of: "/", with: "-")
        if path.first == "-" {
            path.removeFirst()
        }
        
        guard let url = URL(string: recentFile.fileURL) else {
            AmahiLogger.log("Invalid file URL, file cannot be downloaded")
            return
        }
        
        let offlineFile = OfflineFile(name: recentFile.fileName, mime: recentFile.mimeType, size: recentFile.sizeNumber, mtime: recentFile.mtimeDate, fileUri: url.absoluteString, localPath: path, progress: 0, state: .downloading, context: stack.context)
        
        
        OfflineFileIndexesRecents.offlineFilesIndexPaths[offlineFile] = indexPath
        OfflineFileIndexesRecents.indexPathsForOfflineFiles[indexPath] = offlineFile
        
        try? stack.saveContext()
        
        DownloadService.shared.startDownload(offlineFile)
        loadOfflineFiles()
    }
    
    func removeOfflineFile(indexPath: IndexPath){
        if let offlineFile = OfflineFileIndexesRecents.indexPathsForOfflineFiles[indexPath]{
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
            NotificationCenter.default.post(name: .OfflineFileDeleted, object: offlineFile, userInfo: ["loadOfflineFiles": true])
        }
    }
    
    func loadOfflineFiles(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OfflineFile")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "downloadDate", ascending: false)]
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: stack.context,
                                                              sectionNameKeyPath: nil, cacheName: nil)
        if let files = fetchedResultsController?.fetchedObjects as! [OfflineFile]? {
            
            var dictionary = [String : OfflineFile]()
            
            for file in files {
                dictionary[file.name!] = file
            }
            AmahiLogger.log("Offline Files \(dictionary)")
            
            self.offlineFiles = dictionary
        } else {
            AmahiLogger.log("Detched Objects returned was nil")
            self.offlineFiles = [:]
        }
    }
    
    func checkFileOfflineState(_ file: Recent) -> OfflineFileState {
        
        if let offlineFile = offlineFiles![file.fileName] {
            
            if file.mtimeDate != offlineFile.mtime! {
                return .outdated
            }
            
            return offlineFile.stateEnum
        } else {
            return .none
        }
    }
    
    func getOfflineFileFromRecentFile(_ file: Recent) -> OfflineFile?{
        return offlineFiles?[file.fileName]
    }
    
    func downloadFile(recentFile: Recent, completion: @escaping(_ filePath: URL) -> Void){
        updateDownloadProgress(recentFile: recentFile, downloadJustStarted: true, progress: 0.0)
        
        // cleanup temp files in background
        DispatchQueue.global(qos: .background).async {
            FileManager.default.cleanUpFiles(in: FileManager.default.temporaryDirectory,
                                             folderName: "cache")
        }
        
        Network.shared.downloadRecentFileToStorage(recentFile: recentFile, progressCompletion: { (progress) in
            self.updateDownloadProgress(recentFile: recentFile, downloadJustStarted: false, progress: progress)
        }) { (wasSuccessfull) in
            if !wasSuccessfull{
                self.showError(message: StringLiterals.errorDownloadingFileMessage)
                return
            }
            
            let filePath = FileManager.default.localPathInCache(for: recentFile)
            
            self.dismissProgressIndicator(completion: {
                completion(filePath)
            })
        }
    }
    
}
