//
//  FilteredServerFiles.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 18..
//  Copyright © 2019. Amahi. All rights reserved.
//

import Foundation
import Lightbox
import AVFoundation


struct FilteredServerFiles{
    var sectionNames: [String?]
    var sectionFiles: [[ServerFile]]
    var filesCounter: Int
    var folderCounter: Int
    
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
    
    init() {
        sectionNames = [String]()
        sectionFiles = [[ServerFile]]()
        filesCounter = 0
        folderCounter = 0
        
        imageFilesIndexPaths = [IndexPath]()
        audioFilesIndexPaths = [IndexPath]()
    }
    
    mutating func reset(){
        sectionNames.removeAll()
        sectionFiles.removeAll()
        filesCounter = 0
        folderCounter = 0
        
        imageFilesIndexPaths.removeAll()
        audioFilesIndexPaths.removeAll()
    }
    
    func getFileFromIndexPath(_ indexPath: IndexPath) -> ServerFile{
        return sectionFiles[indexPath.section][indexPath.item]
    }
    
    mutating func addNewSection(sectionName: String?, files: [ServerFile]){
        sectionNames.append(sectionName)
        sectionFiles.append([ServerFile]())
        
        for file in files{
            addNewFileToEnd(file: file)
        }
    }
    
    mutating func addNewFileToEnd(file: ServerFile){
        let sectionIndex = sectionFiles.count - 1
        addNewFile(sectionIndex: sectionIndex, file: file)
    }
    
    mutating func addNewFileToBeginning(file: ServerFile){
        addNewFile(sectionIndex: 0, file: file)
    }
    
    private mutating func addNewFile(sectionIndex: Int, file: ServerFile){
        sectionFiles[sectionIndex].append(file)
        updateCounter(file: file)
        
        let itemIndex = sectionFiles[sectionIndex].count-1
        if file.mimeType == .image{
            imageFilesIndexPaths.append(IndexPath(item: itemIndex, section: sectionIndex))
        }else if file.mimeType == .audio{
            audioFilesIndexPaths.append(IndexPath(item: itemIndex, section: sectionIndex))
        }
        
        if let offlineFile = file.getOfflineFile(){
            OfflineFileIndexes.offlineFilesIndexPaths[offlineFile] = IndexPath(item: itemIndex, section: sectionIndex)
            OfflineFileIndexes.indexPathsForOfflineFiles[IndexPath(item: itemIndex, section: sectionIndex)] = offlineFile
        }
    }
    
    mutating func updateCounter(file: ServerFile){
        if file.isDirectory{
            folderCounter += 1
        }else{
            filesCounter += 1
        }
    }
    
    func isEmpty() -> Bool {
        return sectionCounter == 0
    }
    
    func filesCounterInSection(_ sectionIndex: Int) -> Int {
        return sectionFiles[sectionIndex].count
    }
    
    func getImageFiles(selectedFile: ServerFile) -> (startIndex: Int, images: [LightboxImage]) {
        var images = [LightboxImage]()
        var startIndex = 0
        
        for indexPath in imageFilesIndexPaths{
            let file = getFileFromIndexPath(indexPath)
            
            guard let url = ServerApi.shared?.getFileUri(file) else {
                AmahiLogger.log("Invalid file URL, file cannot be opened")
                continue
            }
            
            images.append(LightboxImage(imageURL: url, text: file.name ?? ""))
            
            if file == selectedFile{
                startIndex = images.count - 1
            }
        }
        
        return (startIndex, images)
    }
    
    func getAudioFiles(selectedFile: ServerFile) -> (startIndex: Int, playerItems: [AVPlayerItem], urls: [URL]) {
        var playerItems = [AVPlayerItem]()
        var urls = [URL]()
        var startIndex = 0
        
        for indexPath in audioFilesIndexPaths{
            let file = getFileFromIndexPath(indexPath)
            
            guard let url = ServerApi.shared?.getFileUri(file) else {
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
    

    
}
