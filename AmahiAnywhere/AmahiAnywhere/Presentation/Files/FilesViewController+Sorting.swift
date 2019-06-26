//
//  FilesViewController+SortingDelegates.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 18..
//  Copyright © 2019. Amahi. All rights reserved.
//

import Foundation

extension FilesViewController{
    
    func getSorter(_ sortOrder: FileSort) -> ((ServerFile, ServerFile) -> Bool) {
        switch sortOrder {
        case .modifiedTime:
            return ServerFile.lastModifiedSorter
        case .name:
            return ServerFile.nameSorter
        case .size:
            return ServerFile.sizeSorter
        case .type:
            return ServerFile.typeSorter
        }
    }
    
    func organizeSectionsByName(files: [ServerFile]){
        for file in files{
            guard var firstChar = file.name?.first else { continue }
            if !firstChar.isLetter{
                firstChar = "#"
            }else{
                firstChar = Character(String(firstChar).uppercased())
            }
            
            if filteredFiles.isEmpty() || filteredFiles.lastSectionName != String(firstChar){
                filteredFiles.addNewSection(sectionName: String(firstChar), files: [file])
            }else{
                filteredFiles.addNewFileToEnd(file: file)
            }
        }
    }
    
    func organizeSectionsByModified(files: [ServerFile]){
        for file in files{
            guard let date = file.mtime else { continue }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            let dateFormatted = dateFormatter.string(from: date)
            if filteredFiles.isEmpty() || filteredFiles.lastSectionName != dateFormatted{
                filteredFiles.addNewSection(sectionName: dateFormatted, files: [file])
            }else{
                filteredFiles.addNewFileToEnd(file: file)
            }
        }
    }
    
    func organizeSectionsBySize(files: [ServerFile]){
        filteredFiles.addNewSection(sectionName: nil, files: files)
    }
    
    func organizeSectionsByType(files: [ServerFile]){
        for file in files{
            if file.isDirectory{
                if filteredFiles.isEmpty(){
                    filteredFiles.addNewSection(sectionName: "Folders", files: [file])
                }else{
                    filteredFiles.addNewFileToBeginning(file: file)
                }
            }else{
                if filteredFiles.isEmpty() || (filteredFiles.sectionCounter == 1 && filteredFiles.firstSectionName == "Folders"){
                    filteredFiles.addNewSection(sectionName: "Files", files: [file])
                }else{
                    filteredFiles.addNewFileToEnd(file: file)
                }
            }
        }
    }
}
