//
//  AudioPlayerQueueViewController.swift
//  AmahiAnywhere
//
//  Created by Shresth Pratap Singh on 07/06/20.
//  Copyright © 2020 Amahi. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioPlayerQueueDelegate : class{
    func didDeleteItem(at indexPath:IndexPath)
    func didMoveItem(from sourceIndexPath:IndexPath, to destinationIndexPath: IndexPath)
    func shouldPlay(item:AVPlayerItem,at indexPath:IndexPath)
}

class AudioPlayerQueueViewController:UIViewController{
    
    let cellID = "trackCell"
    weak var delegate:AudioPlayerQueueDelegate?
    var dataModel = AudioPlayerDataModel.shared

    lazy var tableView:UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    //MARK:- VC Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        tableView.register(UINib(nibName: "QueueItemTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        tableView.semanticContentAttribute = .forceRightToLeft
        tableView.backgroundColor = UIColor(named: "tabBarBackground")

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .audioPlayerQueuedItemsDidUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .audioPlayerShuffleStatusChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .audioPlayerDidSetMetaData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .playerQueueDidReset, object: nil)
    }
    
    @objc func refresh(){
        tableView.reloadData()
    }
    
}

//MARK:- TableView Delegate And DataSource

extension AudioPlayerQueueViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.getRowCountForTV()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? QueueItemTableViewCell else {
            return UITableViewCell()
        }
        let baseIndex = indexPath.row + (dataModel.currentIndex + 1)
        if baseIndex < dataModel.playerItems.count{
            let songItem = dataModel.playerItems[baseIndex]
            if let data = dataModel.metadata[songItem]{
                cell.titleLabel.text = data.title ?? "Title"
                cell.artistLabel.text = data.artist ?? "Artist"
                cell.thumbnailView.image = data.image ?? UIImage(named:"musicPlayerArtWork")
            }
            else {
               let data = dataModel.fetchAndSaveMetaData(for: songItem)
                cell.titleLabel.text = data?.title ?? "Title"
                cell.artistLabel.text = data?.artist ?? "Artist"
                cell.thumbnailView.image = data?.image ?? UIImage(named:"musicPlayerArtWork")
            }
        }else{
            cell.titleLabel.text = "Title"
            cell.artistLabel.text = "Artist"
            cell.thumbnailView.image = UIImage(named:"musicPlayerArtWork")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //prefetching metadata for coming up cells
        if dataModel.getRowCountForTV() - indexPath.row <= 12 {
            if dataModel.totalFetchedSongs < (dataModel.playerItems.count) && !dataModel.isFetchingMetadata {
                let singleFetchMaxCount = 12
                let frontRemaining = max(0, dataModel.playerItems.count - (dataModel.startIndex + dataModel.totalFetchedSongs))
                let remainingInBack = min(dataModel.startIndex, (singleFetchMaxCount - frontRemaining))
                
                let frontToBeFetched = min(singleFetchMaxCount, frontRemaining)
                if frontToBeFetched > 0 {
                    dataModel.fetchMetaData(from: dataModel.startIndex + dataModel.totalFetchedSongs, to:  dataModel.startIndex + dataModel.totalFetchedSongs + frontToBeFetched - 1)
                }
                if remainingInBack > 0 {
                    dataModel.fetchMetaData(from: 0, to: max(0,remainingInBack)-1)
                }
            }
        }

    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Remove") { (acion, indexPath) in
            let baseIndex = indexPath.row + (self.dataModel.currentIndex + 1)
            let item = self.dataModel.playerItems.remove(at: baseIndex)
            self.dataModel.metadata.removeValue(forKey: item)
            self.dataModel.totalFetchedSongs -= 1
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.delegate?.didDeleteItem(at: indexPath)
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let baseIndex = indexPath.row + (dataModel.currentIndex + 1)
        dataModel.prepareToPlay(at:baseIndex)
        if let parent = delegate as? AudioPlayerViewController{
            parent.playNextSong(whileOverridingRepeatCurrent: true)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceRow = sourceIndexPath.row + (dataModel.currentIndex + 1)
        let destinationRow = destinationIndexPath.row + (dataModel.currentIndex + 1)
        if sourceRow < dataModel.playerItems.count && destinationRow < dataModel.playerItems.count{
            let item = dataModel.playerItems.remove(at: sourceRow)
            dataModel.playerItems.insert(item, at: destinationRow)
            delegate?.didMoveItem(from: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch UIDevice().userInterfaceIdiom {
        case .tv,.pad:
            return 110
        default:
            return 65
        }
    }
    
}
