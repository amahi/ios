//
//  QueueViewController.swift
//  AmahiAnywhere
//
//  Created by Abhishek Sansanwal on 15/07/19.
//  Copyright © 2019 Amahi. All rights reserved.
//

import UIKit
import GoogleCast

class QueueViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
GCKSessionManagerListener, GCKRemoteMediaClientListener, GCKRequestDelegate, GCKMediaQueueDelegate {
    
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet private var _tableView: UITableView!
    @IBOutlet private var _editButton: UIBarButtonItem!
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if #available(iOS 13.0, *) {
            self.view.tintColor = UIColor.label
        } else {
            self.view.tintColor = UIColor.white
        }
    }
    
    private var _editing = false
    private var mediaClient: GCKRemoteMediaClient!
    private var mediaController: GCKUIMediaController!
    private var queueRequest: GCKRequest!
    
    override func viewDidLoad() {
        _tableView.dataSource = self
        _tableView.delegate = self
        _editing = false
        let sessionManager = GCKCastContext.sharedInstance().sessionManager
        sessionManager.add(self)
        if sessionManager.hasConnectedCastSession() {
            attach(to: sessionManager.currentCastSession!)
        }
        _tableView.separatorColor = UIColor.systemGray
        setItemsLabel()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.secondarySystemBackground
            _tableView.backgroundColor = UIColor.secondarySystemBackground
            _editButton.tintColor = UIColor.label
        } else {
            self.view.backgroundColor = UIColor(hex: "1E2023")
            _tableView.backgroundColor = UIColor(hex: "1E2023")
            _editButton.tintColor = UIColor.white
        }
        super.viewDidLoad()
    }
    
    func setItemsLabel(){
        itemsLabel.text = "Items in the queue: \(mediaClient?.mediaQueue.itemCount ?? 0)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        appDelegate?.isCastControlBarsEnabled = false
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        queueRequest = nil
        _tableView.isUserInteractionEnabled = true
        if (mediaClient?.mediaQueue.itemCount ?? 0) == 0 {
            _editButton.isEnabled = false
        } else {
            _editButton.isEnabled = true
        }
        _tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func toggleEditing(_: Any) {
        toggleEditingButton()
    }
    
    func toggleEditingButton(){
        if _editing {
            _editButton.title = "Edit"
            _tableView.setEditing(false, animated: true)
            _editing = false
            if mediaClient.mediaQueue.itemCount == 0 {
                _editButton.isEnabled = false
            }
        } else {
            _editButton.title = "Done"
            _tableView.setEditing(true, animated: true)
            _editing = true
        }
    }
    
    func showErrorMessage(_ message: String) {
        let alert = UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func attach(to castSession: GCKCastSession) {
        mediaClient = castSession.remoteMediaClient
        mediaClient.add(self)
        _tableView.reloadData()
    }
    
    func detachFromCastSession() {
        mediaClient.remove(self)
        mediaClient = nil
        _tableView.reloadData()
    }
    
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }
    
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if (mediaClient == nil) || (mediaClient.mediaStatus == nil) {
            return 0
        }
        setItemsLabel()
        return Int(mediaClient.mediaQueue.itemCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaCell", for: indexPath)
        let mediaTitleLabel: UILabel? = (cell.viewWithTag(1) as? UILabel)
        let mediaOwnerLabel: UILabel? = (cell.viewWithTag(2) as? UILabel)
        
        let item: GCKMediaQueueItem? = mediaClient.mediaQueue.item(at: UInt(indexPath.row))
        if item == nil {
            mediaTitleLabel?.text = "Loading..."
            mediaOwnerLabel?.text = "Loading..."
            return cell
        }
        
        let title: String? = item?.mediaInformation.metadata?.string(forKey: kGCKMetadataKeyTitle)
        mediaTitleLabel?.text = title
        var artist: String? = item?.mediaInformation.metadata?.string(forKey: kGCKMetadataKeySubtitle)
        if artist == nil {
            artist = "/video"
        }
        // let duration = (item?.mediaInformation.streamDuration == Double.infinity) ? "" :
        // GCKUIUtils.timeInterval(asString: (item?.mediaInformation.streamDuration)!)
        mediaOwnerLabel?.text = artist
        if mediaClient.mediaStatus?.currentItemID == item?.itemID {
            cell.backgroundColor = UIColor(red: CGFloat(15.0 / 255), green: CGFloat(153.0 / 255),
                                           blue: CGFloat(242.0 / 255), alpha: CGFloat(0.1))
        } else {
            cell.backgroundColor = nil
        }
        
        let imageView = (cell.contentView.viewWithTag(3) as? UIImageView)
        if let image = VideoThumbnailGenerator.imageFromMemory(for: (item?.mediaInformation.contentURL)!) {
            imageView!.image = image
        } else {
            imageView!.image = UIImage(named: "video")
            DispatchQueue.global(qos: .background).async {
                let image = VideoThumbnailGenerator().getThumbnail((item?.mediaInformation.contentURL)!)
                DispatchQueue.main.async {
                    imageView!.image = image
                }
            }
        }
        //Uncomment the next lines when thumbnails are fetched from Amahi servers
        /*if let images = item?.mediaInformation.metadata?.images(), images.count > 0 {
         let image = images[0] as? GCKImage
         GCKCastContext.sharedInstance().imageCache?.fetchImage(for: (image?.url)!,
         completion: { (_ image: UIImage?) -> Void in
         imageView?.image = image
         cell.setNeedsLayout()
         })
         }*/
        cell.setNeedsLayout()
        return cell
    }
    
    func tableView(_: UITableView, canMoveRowAt _: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.row == destinationIndexPath.row {
            return
        }
        let sourceItem = mediaClient.mediaQueue.item(at: UInt(sourceIndexPath.row))
        var insertBeforeID = kGCKMediaQueueInvalidItemID
        if destinationIndexPath.row < Int(mediaClient.mediaQueue.itemCount) - 1 {
            let beforeItem: GCKMediaQueueItem? = mediaClient.mediaQueue.item(at: UInt(destinationIndexPath.row))
            insertBeforeID = (beforeItem?.itemID)!
        }
        start(mediaClient.queueMoveItem(withID: (sourceItem?.itemID)!, beforeItemWithID: insertBeforeID))
    }
    
    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete row.
            let item: GCKMediaQueueItem? = mediaClient.mediaQueue.item(at: UInt(indexPath.row))
            if item != nil {
                start(mediaClient.queueRemoveItem(withID: (item?.itemID)!))
            }
        }
    }
    
    func tableView(_: UITableView, didEndEditingRowAt _: IndexPath?) {}
    
    // MARK: - GCKSessionManagerListener
    
    func sessionManager(_: GCKSessionManager, didStart session: GCKCastSession) {
        attach(to: session)
    }
    
    func sessionManager(_: GCKSessionManager, didSuspend _: GCKCastSession,
                        with _: GCKConnectionSuspendReason) {
        detachFromCastSession()
    }
    
    func sessionManager(_: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        attach(to: session)
    }
    
    func sessionManager(_: GCKSessionManager, willEnd _: GCKCastSession) {
        detachFromCastSession()
    }
    
    // MARK: - GCKRemoteMediaClientListener
    
    func remoteMediaClient(_: GCKRemoteMediaClient, didUpdate _: GCKMediaStatus?) {
        _tableView.reloadData()
    }
    
    func remoteMediaClientDidUpdateQueue(_: GCKRemoteMediaClient) {
        _tableView.reloadData()
    }
    
    // MARK: - Request scheduling
    
    func start(_ request: GCKRequest) {
        queueRequest = request
        queueRequest.delegate = self
        _tableView.isUserInteractionEnabled = false
    }
    
    // MARK: - GCKRequestDelegate
    
    func requestDidComplete(_ request: GCKRequest) {
        if request == queueRequest {
            queueRequest = nil
            _tableView.isUserInteractionEnabled = true
        }
        setItemsLabel()
    }
    
    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        if request == queueRequest {
            queueRequest = nil
            _tableView.isUserInteractionEnabled = true
            showErrorMessage("Queue request failed:\n\(error.description)")
        }
        setItemsLabel()
    }
    
    func requestWasReplaced(_ request: GCKRequest) {
        if request == queueRequest {
            queueRequest = nil
            _tableView.isUserInteractionEnabled = true
        }
        setItemsLabel()
    }
    
    // MARK: - GCKMediaQueueDelegate
    
    func mediaQueueDidChange(_ queue: GCKMediaQueue) {
        setItemsLabel()
        _tableView.reloadData();
    }
}

