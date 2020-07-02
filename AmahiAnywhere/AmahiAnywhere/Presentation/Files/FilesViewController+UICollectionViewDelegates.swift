//
//  FilesViewController+UITableViewDelegates.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/17/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation
import SDWebImage
import Lightbox
import AVFoundation
import SwipeCellKit

extension FilesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SwipeCollectionViewCellDelegate{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredFiles.sectionCounter
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredFiles.filesCounterInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Configuring Lightbox to use SDWebImage for caching images
        LightboxConfig.loadImage = {
            imageView, URL, completion in
            imageView.sd_setImage(with: URL, placeholderImage: nil, options: .refreshCached, completed: { (image, data, error, true) in
                completion?(nil)
            })
        }
        
        let serverFile = filteredFiles.getFileFromIndexPath(indexPath)
        
        if layoutView == .listView{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as? FilesListCollectionViewCell else{
                return UICollectionViewCell()
            }
            
            cell.setupData(serverFile: serverFile)
            cell.moreButton.addTarget(self, action: #selector(moreButtonTapped(sender:)), for: .touchUpInside)
            cell.delegate = self
            cell.downloadIcon.isHidden = presenter.checkFileOfflineState(serverFile) != .downloaded
            
            if presenter.checkFileOfflineState(serverFile) == .downloading{
                cell.loadingIndicator.isHidden = false
                cell.loadingIndicator.startAnimating()
            }else{
                cell.loadingIndicator.isHidden = true
                cell.loadingIndicator.stopAnimating()
            }
            
            return cell
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath) as? FilesGridCollectionCell else{
                return UICollectionViewCell()
            }
            
            cell.setupData(serverFile: serverFile)
            cell.moreButton.addTarget(self, action: #selector(moreButtonTapped(sender:)), for: .touchUpInside)
            cell.downloadIcon.isHidden = presenter.checkFileOfflineState(serverFile) != .downloaded
            
            if presenter.checkFileOfflineState(serverFile) == .downloading{
                cell.loadingIndicator.isHidden = false
                cell.loadingIndicator.startAnimating()
            }else{
                cell.loadingIndicator.isHidden = true
                cell.loadingIndicator.stopAnimating()
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if layoutView == .listView{
            return CGSize(width: collectionView.frame.width, height: 80)
        }else{
            return CGSize(width: collectionView.frame.width/3, height: 140)
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
            let foldersCoutner = filteredFiles.folderCounter
            
            if foldersCoutner != 0 && filesCounter != 0{
                footerCell.titleLabel.text = "\(foldersCoutner) Folders, \(filesCounter) Files"
            }else if filesCounter == 0 && foldersCoutner == 0{
                footerCell.titleLabel.text = "0 Files"
            }else if filesCounter != 0{
                footerCell.titleLabel.text = "\(filesCounter) Files"
            }else{
                footerCell.titleLabel.text = "\(foldersCoutner) Folders"
            }
            if #available(iOS 13.0, *) {
                footerCell.titleLabel.textColor = UIColor.label
            } else {
                footerCell.titleLabel.textColor = UIColor.white
            }
            
            return footerCell
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let serverFile = filteredFiles.getFileFromIndexPath(indexPath)
        
        if serverFile.isDirectory{
            handleFolderOpening(serverFile: serverFile)
        }else{
            presenter.handleFileOpening(selectedFile: serverFile, indexPath: indexPath, files: filteredFiles, from: collectionView.cellForItem(at: indexPath))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let serverFile = filteredFiles.getFileFromIndexPath(indexPath)
        
        if serverFile.isDirectory{
            return nil
        }else{
            if orientation == .left{
                let shareAction = SwipeAction(style: .default, title: StringLiterals.share) { (action, indexPath) in
                    self.presenter.shareFile(serverFile, fileIndex: indexPath.item, section: indexPath.section, from: self.filesCollectionView.cellForItem(at: indexPath))
                }
                shareAction.backgroundColor = #colorLiteral(red: 0.2704460415, green: 0.5734752943, blue: 1, alpha: 1)
                shareAction.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                if #available(iOS 13.0, *) {
                    shareAction.textColor = .label
                } else {
                    shareAction.textColor = .white
                    
                }
                return [shareAction]
            }else{
                let state = presenter.checkFileOfflineState(serverFile)
                if state == .none{
                    let downloadAction = SwipeAction(style: .default, title: "Download") { (action, indexPath) in
                        self.presenter.makeFileAvailableOffline(serverFile, indexPath)
                    }
                    
                    downloadAction.backgroundColor = #colorLiteral(red: 0.2172219259, green: 0.7408193211, blue: 0.1805167178, alpha: 1)
                    downloadAction.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                    if #available(iOS 13.0, *) {
                        downloadAction.textColor = .label
                    } else {
                        downloadAction.textColor = .white
                    }
                    return [downloadAction]
                }else if state == .downloaded{
                    let removeDownloadAction = SwipeAction(style: .default, title: "Remove Download") { (action, indexPath) in
                        self.removeOfflineFile(indexPath: indexPath)
                    }
                    
                    removeDownloadAction.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.1215686275, blue: 0.1882352941, alpha: 1)
                    if #available(iOS 13.0, *) {
                        removeDownloadAction.textColor = .label
                    } else {
                        removeDownloadAction.textColor = .white
                    }
                    removeDownloadAction.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                    return [removeDownloadAction]
                }else if state == .downloading{
                    let cancelDownloadAction = SwipeAction(style: .default, title: "Cancel Download") { (action, indexPath) in
                        if let offlineFile = OfflineFileIndexes.indexPathsForOfflineFiles[indexPath]{
                            DownloadService.shared.cancelDownload(offlineFile)
                        }
                    }
                    
                    cancelDownloadAction.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.1215686275, blue: 0.1882352941, alpha: 1)
                    if #available(iOS 13.0, *) {
                        cancelDownloadAction.textColor = .label
                    } else {
                        cancelDownloadAction.textColor = .white
                    }
                    cancelDownloadAction.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                    return [cancelDownloadAction]
                }else{
                    return nil
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .selection
        if orientation == .left{
            options.backgroundColor = #colorLiteral(red: 0.2704460415, green: 0.5734752943, blue: 1, alpha: 1)
        }else{
            let file = filteredFiles.getFileFromIndexPath(indexPath)
            let state = presenter.checkFileOfflineState(file)
            if state == .none{
                options.backgroundColor = #colorLiteral(red: 0.2172219259, green: 0.7408193211, blue: 0.1805167178, alpha: 1)
            }else{
                options.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.1215686275, blue: 0.1882352941, alpha: 1)
            }
        }
        return options
    }
}
