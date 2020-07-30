//
//  AudioPlayerViewController+CollectionView.swift
//  AmahiAnywhere
//
//  Created by Shresth Pratap Singh on 14/07/20.
//  Copyright © 2020 Amahi. All rights reserved.
//

import Foundation

extension AudioPlayerViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModel.getItemCountForCV()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: thumbnailCellID, for: indexPath) as? AudioThumbnailCollectionCell else {
            return UICollectionViewCell()
        }
        
    let baseIndex = dataModel.currentIndex + indexPath.item
        
        if baseIndex<dataModel.playerItems.count{
            let item = dataModel.playerItems[baseIndex]
            if let data = dataModel.metadata[item],let image = data.image{
                if let roundedAspectFitImage = image.roundedImage(cornerRadius: 17){
                    cell.imageView.image =  roundedAspectFitImage
                }else{
                    cell.imageView.image = image
                }
            }
            else {
                let data = dataModel.fetchAndSaveMetaData(for: item)
                    cell.imageView.image = data?.image ?? UIImage(named:"musicPlayerArtWork")
                    loadSong()
            }
        }else{
            cell.imageView.image = UIImage(named:"musicPlayerArtWork")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //prefetching metadata for coming up cells
        if dataModel.getItemCountForCV() - indexPath.item <= 12{
            if dataModel.totalFetchedSongs < (dataModel.playerItems.count) && !dataModel.isFetchingMetadata {
                let singleFetchMaxCount = 12
                let frontRemaining = max(0, dataModel.playerItems.count - (dataModel.startIndex + dataModel.totalFetchedSongs))
                let remainingInBack = min(dataModel.startIndex, (singleFetchMaxCount - frontRemaining))
                let frontToBeFetched = min(singleFetchMaxCount, frontRemaining)
                if frontToBeFetched > 0 {
                    dataModel.fetchMetaData(from: dataModel.startIndex + dataModel.totalFetchedSongs, to:  dataModel.startIndex + dataModel.totalFetchedSongs + frontToBeFetched - 1)
                }
                if remainingInBack > 0 {
                    dataModel.fetchMetaData(from: 0, to: max(0,remainingInBack) - 1)
                }
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        let itemWidth = thumbnailCollectionView.bounds.width
        let proportionalOffset = scrollView.contentOffset.x / itemWidth
        swipe(for: proportionalOffset, with: velocity)
    }
    
    func swipe(for offset: CGFloat, with velocity: CGPoint){
        let wholeNumber = Int(offset)
        
        let drag = offset - CGFloat(wholeNumber)
        
        if (drag >= 0.10 || drag <= -0.10){
            if velocity.x < 0{
                playPreviousSong(fromSwipe : true)
            }else{
                playNextSong(whileOverridingRepeatCurrent:true)
            }
        }else{
            thumbnailCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func updateThumbnailCollectionView(for operation : MusicOperation){
        switch operation {
            case .previous:
                thumbnailCollectionView.performBatchUpdates({
                    self.thumbnailCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
                }, completion: nil)
            case .next:
                if thumbnailCollectionView.numberOfItems(inSection: 0) > 0{
                    thumbnailCollectionView.deleteItems(at: [IndexPath(item: 0, section: 0)])
                    thumbnailCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.thumbnailCollectionView.reloadData()
        }
    }
}

enum MusicOperation{
    case previous
    case next
}
