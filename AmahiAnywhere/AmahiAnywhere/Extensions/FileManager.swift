//
//  FileManager.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 5/23/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

extension FileManager {
    
    func createFolderInTemp(folderName: String) -> URL? {
        let fileManager =  self
        let tempDirectory = fileManager.temporaryDirectory
        
        let folderPath = tempDirectory.appendingPathComponent(folderName)
        if !fileManager.fileExists(atPath: folderPath.path) {
            do {
                try fileManager.createDirectory(atPath: folderPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                debugPrint("Error while trying to create folder in temp: \(error.localizedDescription)")

                return nil
            }
        }
        
        return folderPath
    }
    
    func deleteFolderInTemp(folderName: String) {
        do {
            let fileManager =  self
            let tempDirectory = fileManager.temporaryDirectory
            
            let folderPath = tempDirectory.appendingPathComponent(folderName)
            try fileManager.removeItem(at: folderPath)
        } catch {
            debugPrint("Error while trying to delete files: \(error.localizedDescription)")
        }
    }
    
    func cleanUpFilesInCache(folderName: String) {
        do {
            let fileManager =  self
            let tempDirectory = fileManager.temporaryDirectory
            
            let folderPath = tempDirectory.appendingPathComponent(folderName)
            
            let resourceKeys : [URLResourceKey] = [.contentAccessDateKey, .isDirectoryKey]
       
            if !fileExists(atPath: folderPath.path) {
                debugPrint("Cache is empty, no need to proceed with cleanup")
                return
            }
            
            let enumerator = FileManager.default.enumerator(at: folderPath,
                                                            includingPropertiesForKeys: resourceKeys,
                                                            options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                debugPrint("directoryEnumerator error at \(url): ", error)
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
            debugPrint("Error while trying to delete files: \(error.localizedDescription)")
        }
    }
    
    func fileSizeAtPath(path: String) -> Int64 {
        do {
            let fileAttributes = try attributesOfItem(atPath: path)
            let fileSizeNumber = fileAttributes[FileAttributeKey.size] as? NSNumber
            let fileSize = fileSizeNumber?.int64Value
            return fileSize!
        } catch {
            debugPrint("error reading filesize, NSFileManager extension fileSizeAtPath")
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
        } catch {
            debugPrint("error reading directory, NSFileManager extension folderSizeAtPath")
        }
        return size
    }
    
    func format(size: Int64) -> String {
        let folderSizeStr = ByteCountFormatter.string(fromByteCount: size, countStyle: ByteCountFormatter.CountStyle.file)
        return folderSizeStr
    }
}
