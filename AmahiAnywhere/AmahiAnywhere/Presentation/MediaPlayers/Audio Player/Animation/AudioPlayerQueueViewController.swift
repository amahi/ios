//
//  AudioPlayerQueueViewController.swift
//  AmahiAnywhere
//
//  Created by Shresth Pratap Singh on 07/06/20.
//  Copyright © 2020 Amahi. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioPlayerQueueDelegate {
    func didDeleteItem(at indexPath:IndexPath)
    func didMoveItem(from sourceIndexPath:IndexPath, to destinationIndexPath: IndexPath)
    func shouldPlay(item:AVPlayerItem,at indexPath:IndexPath)
}

class AudioPlayerQueueViewController:UIViewController{
    
    let cellID = "trackCell"
    var delegate:AudioPlayerQueueDelegate?
    var dataModel = AudioPlayerDataModel.shared

    lazy var tableView:UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        tableView.register(UINib(nibName: "QueueItemTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        tableView.semanticContentAttribute = .forceRightToLeft
        tableView.backgroundColor = UIColor(named: "tabBarBackground")
        return tableView
    }()
    
    //MARK:- VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshQueue), name: .audioPlayerQueuedItemsDidUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshQueue), name: .audioPlayerShuffleStatusChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshQueue), name: .audioPlayerDidSetMetaData, object: nil)
    }
    
    @objc func refreshQueue(){
        tableView.reloadData()
    }
    
}

//MARK:- TableView Delegate And DataSource

extension AudioPlayerQueueViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.queuedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? QueueItemTableViewCell else {
            return UITableViewCell()
        }
        
        var track:AVPlayerItem?
        
        if indexPath.row <= dataModel.queuedItems.count{
            track = dataModel.queuedItems[indexPath.row]
        }
        
        if track != nil{
            cell.titleLabel.text = dataModel.trackNames[track!] ?? "Title"
            cell.artistLabel.text = dataModel.artistNames[track!] ?? "Artist"
            cell.thumbnailView.image = dataModel.thumbnailImages[track!] ?? UIImage(named:"musicPlayerArtWork")
        }
        
        cell.thumbnailView.layer.cornerRadius = 5
        cell.thumbnailView.clipsToBounds = true
        cell.selectionStyle = .none
        cell.shouldIndentWhileEditing = false
        cell.accessoryView?.widthAnchor.constraint(equalToConstant: 30)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Remove") { (acion, indexPath) in
            self.dataModel.queuedItems.remove(at: indexPath.row)
            self.dataModel.itemURLs.remove(at: indexPath.row)
            self.delegate?.didDeleteItem(at: indexPath)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < dataModel.queuedItems.count{
            let newTrack = dataModel.queuedItems[indexPath.row]
            dataModel.currentPlayerItem = dataModel.queuedItems.remove(at: indexPath.row)
            dataModel.itemURLs.remove(at: indexPath.row)
            delegate?.shouldPlay(item: newTrack, at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }else{
            let alert = UIAlertController(title: "Oops! coud not load track", message: nil, preferredStyle: .alert)
            present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if sourceIndexPath.row < dataModel.queuedItems.count && destinationIndexPath.row < dataModel.queuedItems.count{
            let item = dataModel.queuedItems.remove(at: sourceIndexPath.row)
            let url = dataModel.itemURLs.remove(at: sourceIndexPath.row)
            dataModel.queuedItems.insert(item, at: destinationIndexPath.row)
            dataModel.itemURLs.insert(url, at: destinationIndexPath.row)
            delegate?.didMoveItem(from: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch UIDevice().userInterfaceIdiom {
        case .tv,.pad:
            return 100
        default:
            return 65
        }
    }
    
}
