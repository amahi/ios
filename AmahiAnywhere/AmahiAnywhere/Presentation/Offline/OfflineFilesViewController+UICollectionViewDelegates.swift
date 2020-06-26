//
//  OfflineFilesViewController+UICollectionViewDelegates.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 28..
//  Copyright © 2019. Amahi. All rights reserved.
//

import Foundation
import SwipeCellKit

extension OfflineFilesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SwipeCollectionViewCellDelegate{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredFiles.sectionCounter
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredFiles.filesCounterInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let offlineFile = filteredFiles.getFileFromIndexPath(indexPath)
        
        if layoutView == .listView{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as? DownloadsListCollectionCell else {
                return UICollectionViewCell()
            }
        
            cell.setupData(offlineFile: offlineFile)
            cell.moreButton.addTarget(self, action: #selector(moreButtonTapped(sender:)), for: .touchUpInside)
            cell.delegate = self
            
            AmahiLogger.log("Offline File State at index: \(indexPath.row) \(offlineFile.stateEnum) with progress \(offlineFile.progress)")
            return cell
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath) as? DownloadsGridCollectionCell else {
                return UICollectionViewCell()
            }
            
            cell.setupData(offlineFile: offlineFile)
            cell.moreButton.addTarget(self, action: #selector(moreButtonTapped(sender:)), for: .touchUpInside)
    
            AmahiLogger.log("Offline File State at index: \(indexPath.row) \(offlineFile.stateEnum) with progress \(offlineFile.progress)")
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if layoutView == .listView{
            return CGSize(width: collectionView.frame.width, height: 80)
        }else{
            return CGSize(width: collectionView.frame.width/3, height: 150)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if filteredFiles.sectionNames[section] == nil{
            return .zero
        }else{
            return CGSize(width: collectionView.frame.width, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section != filteredFiles.sectionCounter - 1{
            return .zero
        }else{
            return CGSize(width: collectionView.frame.width, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
            guard let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? FilesCollectionHeaderView else {
                return UICollectionReusableView()
            }
            
            headerCell.titleLabel.text = filteredFiles.sectionNames[indexPath.section]
            if #available(iOS 13.0, *) {
                                      headerCell.titleLabel.textColor = UIColor.label
                                  } else {
                                      headerCell.titleLabel.textColor = UIColor.white
                                  }
            return headerCell
        }else{
            guard let footerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as? FilesCollectionFooterView else {
                return UICollectionReusableView()
            }
            
            let filesCounter = filteredFiles.filesCounter
            footerCell.titleLabel.text = "\(filesCounter) Files"
            if #available(iOS 13.0, *) {
                           footerCell.titleLabel.textColor = UIColor.label
                       } else {
                           footerCell.titleLabel.textColor = UIColor.white
                       }
            return footerCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let offlineFile = filteredFiles.getFileFromIndexPath(indexPath)
        
        if offlineFile.stateEnum == .downloaded {
            presenter.handleOfflineFile(selectedFile: offlineFile, indexPath: indexPath, files: filteredFiles, from: collectionView.cellForItem(at: indexPath))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let offlineFile = filteredFiles.getFileFromIndexPath(indexPath)
        
        if orientation == .right && offlineFile.stateEnum == .downloaded{
            let deleteAction = SwipeAction(style: .default, title: StringLiterals.delete) { (action, indexPath) in
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
            
            deleteAction.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.1215686275, blue: 0.1882352941, alpha: 1)
            if #available(iOS 13.0, *) {
                deleteAction.textColor = .label
            } else {
                deleteAction.textColor = .white
            }
            deleteAction.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            return [deleteAction]
        }else if orientation == .left && offlineFile.stateEnum == .downloaded, let url = FileManager.default.localFilePathInDownloads(for: offlineFile){
            let shareAction = SwipeAction(style: .default, title: StringLiterals.share) { (action, indexPath) in
                self.shareFile(at: url, from: collectionView.cellForItem(at: indexPath))
            }
            
            shareAction.backgroundColor = #colorLiteral(red: 0.2704460415, green: 0.5734752943, blue: 1, alpha: 1)
            shareAction.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            if #available(iOS 13.0, *) {
                shareAction.textColor = .label
            } else {
                shareAction.textColor = .white
            }
            return [shareAction]
        }else if orientation == .right && offlineFile.stateEnum == .downloading{
            let cancelDownloadAction = SwipeAction(style: .default, title: StringLiterals.stopDownload) { (action, indexPath) in
                // Cancel download
                DownloadService.shared.cancelDownload(offlineFile)
            }
            
            cancelDownloadAction.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.1215686275, blue: 0.1882352941, alpha: 1)
            if #available(iOS 13.0, *) {
                cancelDownloadAction.textColor = .label
            } else {
                cancelDownloadAction.textColor = .white
            }
            cancelDownloadAction.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            return [cancelDownloadAction]
        }
        
        
        else{
            return nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
    
        options.expansionStyle = .selection
        if orientation == .left{
            options.backgroundColor = #colorLiteral(red: 0.2704460415, green: 0.5734752943, blue: 1, alpha: 1)
        }else{
            options.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.1215686275, blue: 0.1882352941, alpha: 1)
        }
        
        return options
    }
    
}
