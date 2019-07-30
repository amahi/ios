//
//  DownloadService.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/17/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

// Downloads server file, and stores in local file.
// Allows cancel, pause, resume download.
class DownloadService : NSObject {
    
    static let shared = DownloadService()
    static let BackgroundIdentifier = "\(Bundle.main.bundleIdentifier!).background"

    var activeDownloads: [URL: Download] = [:]
    
    // Create downloadsSession here, to set self as delegate
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: DownloadService.BackgroundIdentifier)
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    // MARK: - Download methods called in Server FilesViewController delegate methods
    
    func startDownload(_ offlineFile: OfflineFile) {
        if let url = offlineFile.remoteFileURL() {
            offlineFile.stateEnum = .downloading
            NotificationCenter.default.post(name: .DownloadStarted, object: offlineFile, userInfo: nil)
            AmahiLogger.log("Download Has Started for url \(url)")
            let download = Download(offlineFile: offlineFile)
            download.task = downloadsSession.downloadTask(with: url)
            download.task!.resume()
            download.isDownloading = true
            
            activeDownloads[url] = download
            updateTabBarStarted()
        }
    }
    
    func pauseDownload(_ offlineFile: OfflineFile) {
        guard let url = offlineFile.remoteFileURL() else { return }

        guard let download = activeDownloads[url] else { return }
        
        if download.isDownloading {
            download.task?.cancel(byProducingResumeData: { data in
                download.resumeData = data
            })
            download.isDownloading = false
        }
    }
    
    func cancelDownload(_ offlineFile: OfflineFile) {
        guard let url = offlineFile.remoteFileURL() else { return }

        if let download = activeDownloads[url] {
            download.task?.cancel()
            activeDownloads.removeValue(forKey: url)
        }
        
        updateTabBarCompleted()
        
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
        NotificationCenter.default.post(name: .DownloadCancelled, object: offlineFile, userInfo: ["loadOfflineFiles":true])
    }
    
    func resumeDownload(_ offlineFile: OfflineFile) {
        guard let url = offlineFile.remoteFileURL() else { return }

        guard let download = activeDownloads[url] else { return }
        if let resumeData = download.resumeData {
            download.task = downloadsSession.downloadTask(withResumeData: resumeData)
        } else {
            download.task = downloadsSession.downloadTask(with: url)
        }
        download.task!.resume()
        download.isDownloading = true
    }
    
    func updateTabBarCompleted(){
        NotificationCenter.default.post(name: .UpdateTabBarCompleted, object: nil)
    }
    
    func updateTabBarStarted(){
        NotificationCenter.default.post(name: .UpdateTabBarStarted, object: nil)
    }
}


