//
//  FilteredOfflineFile.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 28..
//  Copyright © 2019. Amahi. All rights reserved.
//

import Foundation
import Lightbox
import AVFoundation

struct FilteredOfflineFiles {
    var sectionNames: [String?]
    var sectionFiles: [[OfflineFile]]
    var filesCounter: Int
    var indexPathsDict: [OfflineFile: IndexPath]
    
    var imageFilesIndexPaths: [IndexPath]
    var audioFilesIndexPaths: [IndexPath]
    
    var sectionCounter: Int {
        return sectionFiles.count
    }
    
    var firstSectionName: String? {
        return sectionNames[0]
    }
    
    var lastSectionName: String?{
        return sectionNames[sectionNames.count-1]
    }
    
    init(){
        sectionNames = [String]()
        sectionFiles = [[OfflineFile]]()
        indexPathsDict = [OfflineFile : IndexPath]()
        filesCounter = 0
        
        imageFilesIndexPaths = [IndexPath]()
        audioFilesIndexPaths = [IndexPath]()
    }
    
    mutating func reset(){
        sectionNames.removeAll()
        sectionFiles.removeAll()
        indexPathsDict.removeAll()
        filesCounter = 0
        
        imageFilesIndexPaths.removeAll()
        audioFilesIndexPaths.removeAll()
    }
    
    func getFileFromIndexPath(_ indexPath: IndexPath) -> OfflineFile{
        return sectionFiles[indexPath.section][indexPath.item]
    }
    
    mutating func addNewSection(sectionName: String?, files: [OfflineFile]){
        sectionNames.append(sectionName)
        sectionFiles.append([OfflineFile]())
        
        for file in files{
            addNewFileToEnd(file: file)
        }
    }
    
    mutating func addNewFileToEnd(file: OfflineFile){
        let sectionIndex = sectionFiles.count - 1
        addNewFile(sectionIndex: sectionIndex, file: file)
    }
    
    mutating func addNewFileToBeginning(file: OfflineFile){
        addNewFile(sectionIndex: 0, file: file)
    }
    
    private mutating func addNewFile(sectionIndex: Int, file: OfflineFile){
        sectionFiles[sectionIndex].append(file)
        filesCounter += 1
        
        let itemIndex = sectionFiles[sectionIndex].count-1
        indexPathsDict[file] = IndexPath(item: itemIndex, section: sectionIndex)
        
        if file.mimeType == .image{
            imageFilesIndexPaths.append(IndexPath(item: itemIndex, section: sectionIndex))
        }else if file.mimeType == .audio{
            audioFilesIndexPaths.append(IndexPath(item: itemIndex, section: sectionIndex))
        }
    }
    
    func getImageFiles(selectedFile: OfflineFile) -> (startIndex: Int, images: [LightboxImage]) {
        var images = [LightboxImage]()
        var startIndex = 0
        
        for indexPath in imageFilesIndexPaths{
            let file = getFileFromIndexPath(indexPath)
            
            guard let fileURL = FileManager.default.localFilePathInDownloads(for: file),
                let image = UIImage(contentsOfFile: fileURL.path) else {
                AmahiLogger.log("Invalid file URL, file cannot be opened")
                continue
            }
            
            images.append(LightboxImage(image: image, text: file.name ?? ""))
            
            if file == selectedFile{
                startIndex = images.count - 1
            }
        }
        
        return (startIndex, images)
    }
    
    func getAudioFiles(selectedFile: OfflineFile) -> (startIndex: Int, playerItems: [AVPlayerItem], urls: [URL]) {
        var playerItems = [AVPlayerItem]()
        var urls = [URL]()
        var startIndex = 0
        
        for indexPath in audioFilesIndexPaths{
            let file = getFileFromIndexPath(indexPath)
            
            guard let url = FileManager.default.localFilePathInDownloads(for: file) else {
                AmahiLogger.log("Invalid file URL, file cannot be opened")
                continue
            }
            
            playerItems.append(AVPlayerItem(url: url))
            urls.append(url)
            
            if file == selectedFile{
                startIndex = playerItems.count - 1
            }
        }
        
        return (startIndex, playerItems, urls)
    }
    
    func isEmpty() -> Bool {
        return sectionCounter == 0
    }
    
    func filesCounterInSection(_ sectionIndex: Int) -> Int {
        return sectionFiles[sectionIndex].count
    }
    
    func getIndexPathFromFile(file: OfflineFile) -> IndexPath?{
        return indexPathsDict[file]
    }    
}
