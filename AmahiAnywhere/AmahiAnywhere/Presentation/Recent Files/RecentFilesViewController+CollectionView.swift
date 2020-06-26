//
//  RecentFilesViewController+CollectionView.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 08. 25..
//  Copyright © 2019. Amahi. All rights reserved.
//

import SwipeCellKit
import Lightbox

extension RecentFilesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SwipeCollectionViewCellDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredRecentFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        LightboxConfig.loadImage = {
            imageView, URL, completion in
            imageView.sd_setImage(with: URL, placeholderImage: nil, options: .refreshCached, completed: { (image, data, error, true) in
                completion?(nil)
            })
        }
        
        let recentFile = filteredRecentFiles[indexPath.item]
        
        if layoutView == .listView{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as? FilesListCollectionViewCell else{
                return UICollectionViewCell()
            }
            cell.delegate = self
            
            if checkFileOfflineState(recentFile) == .downloading{
                cell.loadingIndicator.isHidden = false
                cell.loadingIndicator.startAnimating()
            }else{
                cell.loadingIndicator.isHidden = true
                cell.loadingIndicator.stopAnimating()
            }
            
            cell.downloadIcon.isHidden = checkFileOfflineState(recentFile) != .downloaded
            cell.setupData(recentFile: recentFile)
            cell.moreButton.addTarget(self, action: #selector(moreButtonTapped(sender:)), for: .touchUpInside)
            
            return cell
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath) as? FilesGridCollectionCell else{
                return UICollectionViewCell()
            }
            cell.delegate = self
            
            if checkFileOfflineState(recentFile) == .downloading{
                cell.loadingIndicator.isHidden = false
                cell.loadingIndicator.startAnimating()
            }else{
                cell.loadingIndicator.isHidden = true
                cell.loadingIndicator.stopAnimating()
            }
            
            cell.downloadIcon.isHidden = checkFileOfflineState(recentFile) != .downloaded
            cell.setupData(recentFile: recentFile)
            cell.moreButton.addTarget(self, action: #selector(moreButtonTapped(sender:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        handleFileOpening(recentFile: filteredRecentFiles[indexPath.row], from: collectionView.cellForItem(at: indexPath))
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
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let recentFile = filteredRecentFiles[indexPath.item]
        
        if orientation == .left{
            let shareAction = SwipeAction(style: .default, title: StringLiterals.share) { (action, indexPath) in
                self.shareFile(recentFile, from: self.filesCollectionView.cellForItem(at: indexPath))
            }
            shareAction.backgroundColor = #colorLiteral(red: 0.2704460415, green: 0.5734752943, blue: 1, alpha: 1)
            shareAction.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            shareAction.textColor = .white
            return [shareAction]
        }else{
            let state = checkFileOfflineState(recentFile)
            if state == .none{
                let downloadAction = SwipeAction(style: .default, title: "Download") { (action, indexPath) in
                    self.makeFileAvailableOffline(recentFile, indexPath: indexPath)
                }
                
                downloadAction.backgroundColor = #colorLiteral(red: 0.2172219259, green: 0.7408193211, blue: 0.1805167178, alpha: 1)
                downloadAction.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                downloadAction.textColor = .white
                return [downloadAction]
            }else if state == .downloaded{
                let removeDownloadAction = SwipeAction(style: .default, title: "Remove Download") { (action, indexPath) in
                    self.removeOfflineFile(indexPath: indexPath)
                }
                
                removeDownloadAction.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.1215686275, blue: 0.1882352941, alpha: 1)
                removeDownloadAction.textColor = .white
                removeDownloadAction.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                return [removeDownloadAction]
            }else if state == .downloading{
                let cancelDownloadAction = SwipeAction(style: .default, title: "Cancel Download") { (action, indexPath) in
                    if let offlineFile = OfflineFileIndexesRecents.indexPathsForOfflineFiles[indexPath]{
                        DownloadService.shared.cancelDownload(offlineFile)
                    }
                }
                
                cancelDownloadAction.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.1215686275, blue: 0.1882352941, alpha: 1)
                cancelDownloadAction.textColor = .white
                cancelDownloadAction.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                return [cancelDownloadAction]
            }else{
                return nil
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .selection
        if orientation == .left{
            options.backgroundColor = #colorLiteral(red: 0.2704460415, green: 0.5734752943, blue: 1, alpha: 1)
        }else{
            let recentFile = filteredRecentFiles[indexPath.item]
            let state = checkFileOfflineState(recentFile)
            if state == .none{
                options.backgroundColor = #colorLiteral(red: 0.2172219259, green: 0.7408193211, blue: 0.1805167178, alpha: 1)
            }else{
                options.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.1215686275, blue: 0.1882352941, alpha: 1)
            }
        }
        return options
    }
}
