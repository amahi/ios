//
//  OfflineFilesViewController+Sorting.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 28..
//  Copyright © 2019. Amahi. All rights reserved.
//

import Foundation

extension OfflineFilesViewController{
    
    func updateFileSort(sortingMethod: FileSort){
        UIView.performWithoutAnimation {
            self.sortButton.setTitle(sortingMethod.rawValue, for: .normal)
            self.sortButton.layoutIfNeeded()
        }
        
        fileSort = sortingMethod
        organiseFilesSections(offlineFiles)
    }
    
    func organiseFilesSections(_ files: [OfflineFile]){
        filteredFiles.reset()
        let files = files.sorted(by: getSorter(fileSort))
        
        if fileSort == .name{
            organizeSectionsByName(files: files)
        }else if fileSort == .date{
            organizeSectionsByDate(files: files)
        }else{
            organizeSectionsBySize(files: files)
        }
        
        filesCollectionView.reloadData()
    }
    
    func organizeSectionsByName(files: [OfflineFile]){
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
    
    func organizeSectionsByDate(files: [OfflineFile]){
        for file in files{
            guard let date = file.downloadDate else { continue }
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
    
    func organizeSectionsBySize(files: [OfflineFile]){
        filteredFiles.addNewSection(sectionName: nil, files: files)
    }
    
    func getSorter(_ sortOrder: FileSort) -> ((OfflineFile, OfflineFile) -> Bool) {
        switch sortOrder{
        case .date:
            return OfflineFile.dateCreatedSorter
        case .name:
            return OfflineFile.nameSorter
        default:
            return OfflineFile.sizeSorter
        }
    }    
}

extension OfflineFilesViewController: SortViewDelegate{
    func sortingSelected(sortingMethod: FileSort) {
        dismissSortView()
        
        if sortingMethod == fileSort{
            return
        }
        
        updateFileSort(sortingMethod: sortingMethod)
    }
}
