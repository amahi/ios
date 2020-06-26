//
//  FileManager.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 5/23/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

extension FileManager {
    
    func findOrCreateFolder(in directory: URL, folderName: String) -> URL? {
        let fileManager =  self
        
        var folderPath = directory.appendingPathComponent(folderName)
        if !fileManager.fileExists(atPath: folderPath.path) {
            do {
                try fileManager.createDirectory(atPath: folderPath.path, withIntermediateDirectories: true, attributes: nil)
                // Remove folder from iCloud
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                try folderPath.setResourceValues(resourceValues)
            } catch {
                AmahiLogger.log("Error while trying to create folder in directory \(directory): \(error.localizedDescription)")
                return nil
            }
        }
        
        return folderPath
    }
    
    func deleteFolder(in directory: URL, folderName: String, completion: @escaping(_ success: Bool)->() ) {
        do {
            let fileManager =  self
            let folderPath = directory.appendingPathComponent(folderName)
            try fileManager.removeItem(at: folderPath)
            completion(true)
        } catch let error {
            AmahiLogger.log("Error while trying to delete files: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func cleanUpFiles(in directory: URL, folderName: String) {
        do {
            let fileManager =  self
            
            let folderPath = directory.appendingPathComponent(folderName)
            
            let resourceKeys : [URLResourceKey] = [.contentAccessDateKey, .isDirectoryKey]
       
            if !fileExists(atPath: folderPath.path) {
                AmahiLogger.log("Cache is empty, no need to proceed with cleanup")
                return
            }
            
            let enumerator = FileManager.default.enumerator(at: folderPath,
                                                            includingPropertiesForKeys: resourceKeys,
                                                            options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                AmahiLogger.log("directoryEnumerator error at \(url): ", error)
                                                                return true
            })!
            
            for case let fileURL as URL in enumerator {
                
                if fileURL.isDirectory! {
                    
                    if let lastAccessedDate = fileURL.lastAccessDate {
                        
                        let sevenDaysAgo = Date.daysAgo(days: 7)!
                        
                        if sevenDaysAgo > lastAccessedDate {
                            try fileManager.removeItem(at: fileURL)
                        }
                    }
                }
            }
            
        } catch {
            AmahiLogger.log("Error while trying to delete files: \(error.localizedDescription)")
        }
    }
    
    func fileSizeAtPath(path: String) -> Int64 {
        do {
            let fileAttributes = try attributesOfItem(atPath: path)
            let fileSizeNumber = fileAttributes[FileAttributeKey.size] as? NSNumber
            let fileSize = fileSizeNumber?.int64Value
            return fileSize!
        } catch let error {
            AmahiLogger.log("error reading filesize, NSFileManager extension fileSizeAtPath \(error.localizedDescription)")
            return 0
        }
    }
    
    func folderSizeAtPath(path: String) -> Int64 {
        var size : Int64 = 0
        do {
            let files = try subpathsOfDirectory(atPath: path)
            for i in 0 ..< files.count {
                size += fileSizeAtPath(path:path.appending("/"+files[i]))
            }
        } catch let error {
            AmahiLogger.log("error reading directory, NSFileManager extension folderSizeAtPath \(error.localizedDescription)")
        }
        return size
    }
    
    func format(size: Int64) -> String {
        let folderSizeStr = ByteCountFormatter.string(fromByteCount: size, countStyle: ByteCountFormatter.CountStyle.file)
        return folderSizeStr
    }
    
    func localFilePathInDownloads(for offlineFile: OfflineFile) -> URL? {
        // Get local file path: download task stores tune here
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let downloadFolderPath = FileManager.default.findOrCreateFolder(in: documentsPath, folderName: "downloads")
        
        return downloadFolderPath?.appendingPathComponent(offlineFile.localPath!)
    }
    
    func localPathInCache(for file: ServerFile) -> URL {
        
        let fileManager = self
        let tempDirectory = fileManager.temporaryDirectory
        let cacheFolderPath = tempDirectory.appendingPathComponent("cache")
        
        return cacheFolderPath.appendingPathComponent(file.getPath())
    }
    
    func localPathInCache(for file: Recent) -> URL{
        let fileManager = self
        let tempDirectory = fileManager.temporaryDirectory
        let cacheFolderPath = tempDirectory.appendingPathComponent("cache")
        
        return cacheFolderPath.appendingPathComponent(file.path)
    }
    
    func fileExistsInCache(_ file: ServerFile) -> Bool {
        let fileManager =  self
        let pathComponent = localPathInCache(for: file)

        if fileManager.fileExists(atPath: pathComponent.path) {
            return true
        } else {
            return false
        }
    }
    
    func fileExistsInCache(_ file: Recent) -> Bool {
        let fileManager =  self
        let pathComponent = localPathInCache(for: file)
        
        if fileManager.fileExists(atPath: pathComponent.path) {
            return true
        } else {
            return false
        }
    }
    
    func fileExistsInDownloads(_ file: OfflineFile) -> Bool {
        let fileManager =  self
        let pathComponent = localFilePathInDownloads(for: file)

        if let filePath = pathComponent?.path {
            if fileManager.fileExists(atPath: filePath) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
}
