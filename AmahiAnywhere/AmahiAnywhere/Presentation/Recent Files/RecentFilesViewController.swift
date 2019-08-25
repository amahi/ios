//
//  RecentFilesViewController.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 08. 24..
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit
import Lightbox
import SDWebImage
import AVFoundation
import GoogleCast
import CoreData

class RecentFilesViewController: BaseUIViewController {
    
    internal var recentFiles = [Recent]()
    internal var filteredRecentFiles = [Recent]()
    
    @IBOutlet var layoutButton: UIButton!
    @IBOutlet var filesCollectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    var layoutView: LayoutView!
    let interactor = Interactor()
    
    internal var downloadProgressAlertController : UIAlertController?
    internal var progressView: UIProgressView?
    internal var downloadImageView: UIImageView?
    internal var downloadTitleLabel: UILabel?
    internal var isAlertShowing = false
    
    var offlineFiles : [String: OfflineFile]?
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            executeSearch()
        }
    }
    
    private func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                AmahiLogger.log("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }
    
    enum PlaybackMode: Int {
        case none = 0
        case local
        case remote
    }
    
    enum QueueMedia: Int {
        case none = 0
        case queueItem
        case playItem
    }
    
    var mediaInfo: GCKMediaInformation? {
        didSet {
            print("setMediaInfo: \(String(describing: mediaInfo))")
        }
    }
    
    public var sessionManager: GCKSessionManager!
    public var mediaInformation: GCKMediaInformation?
    public var mediaClient: GCKRemoteMediaClient!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sessionManager = GCKCastContext.sharedInstance().sessionManager
    }
    
    public var playbackMode = PlaybackMode.none
    public var queueMedia = QueueMedia.none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        filesCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionManager.remove(self)
    }
    
    @objc func moreButtonTapped(sender: UIButton){
        let bounds = sender.convert(sender.bounds, to: filesCollectionView)
        handleMoreMenu(touchPoint: bounds.origin)
    }
    
    @objc func handleLongPress(sender: UIGestureRecognizer) {
        handleMoreMenu(touchPoint: sender.location(in: filesCollectionView))
    }
    
    func handleMoreMenu(touchPoint: CGPoint){
        if let indexPath = filesCollectionView.indexPathForItem(at: touchPoint) {
            
            let recentFile = filteredRecentFiles[indexPath.item]
            
            let download = self.creatAlertAction(StringLiterals.download, style: .default) { (action) in
                self.makeFileAvailableOffline(recentFile, indexPath: indexPath)
                }!
            
            let state = checkFileOfflineState(recentFile)
            
            let share = self.creatAlertAction(StringLiterals.share, style: .default) { (action) in
                self.shareFile(recentFile, from: self.filesCollectionView.cellForItem(at: indexPath))
                }!
            
            let removeOffline = self.creatAlertAction(StringLiterals.removeOfflineMessage, style: .default) { (action) in
                self.removeOfflineFile(indexPath: indexPath)
                }!
            
            let stop = self.creatAlertAction(StringLiterals.stopDownload, style: .default) { (action) in
                if let offlineFile = OfflineFileIndexesRecents.indexPathsForOfflineFiles[indexPath]{
                    DownloadService.shared.cancelDownload(offlineFile)
                }
                }!
            
            var actions = [UIAlertAction]()
            actions.append(share)
            
            if state == .none {
                actions.append(download)
            } else if state == .downloaded {
                actions.append(removeOffline)
            } else if state == .downloading {
                actions.append(stop)
            }
            
            let cancel = self.creatAlertAction(StringLiterals.cancel, style: .cancel, clicked: nil)!
            actions.append(cancel)
            
            self.createActionSheet(title: recentFile.fileName,
                                   message: nil,
                                   ltrActions: actions,
                                   preferredActionPosition: 0,
                                   sender: filesCollectionView.cellForItem(at: indexPath))
        }
    }
    
    func setupNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(offlineFileUpdated), name: .DownloadCompletedSuccessfully, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlineFileUpdated), name: .OfflineFileDeleted, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(offlineFileUpdated(_:)), name: .DownloadStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlineFileUpdated(_:)), name: .DownloadCancelled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlineFileUpdated(_:)), name: .DownloadCompletedWithError, object: nil)
    }
    
    func setupLayoutView(){
        layoutView = GlobalLayoutView.layoutView
        
        if layoutView == .listView{
            layoutButton.setImage(UIImage(named: "filesGridIcon"), for: .normal)
        }else{
            layoutButton.setImage(UIImage(named: "filesListIcon"), for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLayoutView()
        loadOfflineFiles()
        loadRecentFiles()
        
        let hasConnectedSession: Bool = (sessionManager.hasConnectedSession())
        if hasConnectedSession, (playbackMode != .remote) {
            
        } else if sessionManager.currentSession == nil, (playbackMode != .local) {
        }
        sessionManager.add(self)
    }
    
    func loadRecentFiles(){
        recentFiles = RecentFiles.sharedInstance.getRecentFiles().reversed()
        updateFilteredFiles(recentFiles: recentFiles)
        filesCollectionView.reloadData()
    }
    
    func updateFilteredFiles(recentFiles: [Recent]){
        filteredRecentFiles.removeAll()
        for (index, recentFile) in recentFiles.enumerated(){
            filteredRecentFiles.append(recentFile)
            if let offlineFile = recentFile.getOfflineFile(){
                OfflineFileIndexesRecents.offlineFilesIndexPaths[offlineFile] = IndexPath(item: index, section: 0)
                OfflineFileIndexesRecents.indexPathsForOfflineFiles[IndexPath(item: index, section: 0)] = offlineFile
            }
        }
    }
    
    @IBAction func layoutButtonTapped(_ sender: UIButton){
        GlobalLayoutView.switchLayoutMode()
        setupLayoutView()
        filesCollectionView.reloadData()
    }
    
    func handleFileOpening(recentFile: Recent, from sender: UIView?){
        let type = recentFile.mimeType
        
        switch type {
        case "image":
            let results = getImageFiles(selectedFile: recentFile)
            let controller = LightboxController(images: results.images, startIndex: results.startIndex)
            controller.dynamicBackground = true
            present(controller, animated: true, completion: nil)
        case "video", "flacMedia":
            playMediaItem(recentFile: recentFile)
        case "audio":
            let results = getAudioFiles(selectedFile: recentFile)
            playAudio(results.playerItems, startIndex: results.startIndex, currentIndex: 0, results.urls)
        case "code", "presentation", "sharedFile", "document", "spreadsheet":
            func handleFileOpening(with fileURL: URL) {
                weak var weakSelf = self
                if type == "sharedFile" {
                    weakSelf?.shareFile(at: fileURL, from: sender)
                } else {
                    weakSelf?.webViewOpenContent(at: fileURL, mimeType: MimeType(type))
                }
            }
            
            if FileManager.default.fileExistsInCache(recentFile) {
                let fileURL = FileManager.default.localPathInCache(for: recentFile)
                handleFileOpening(with: fileURL)
            } else {
                downloadFile(recentFile: recentFile) { (url) in
                    handleFileOpening(with: url)
                }
            }
        default:
            return
        }
    }
    
    func shareFile(_ recentFile: Recent, from sender: UIView?){
        if FileManager.default.fileExistsInCache(recentFile){
            let path = FileManager.default.localPathInCache(for: recentFile)
            shareFile(at: path, from: sender)
        }else{
            downloadFile(recentFile: recentFile) { (url) in
                self.shareFile(at: url, from: sender)
            }
        }
    }
    
    func shareFile(at url: URL, from sender : UIView? ) {
        let linkToShare = [url]
        
        let activityController = UIActivityViewController(activityItems: linkToShare, applicationActivities: nil)
        if let popoverController = activityController.popoverPresentationController, let sender = sender {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(activityController, animated: true, completion: nil)
    }
    
    func getAudioFiles(selectedFile: Recent) -> (startIndex: Int, playerItems: [AVPlayerItem], urls: [URL]){
        var playerItems = [AVPlayerItem]()
        var urls = [URL]()
        var startIndex = 0
        
        for recentFile in filteredRecentFiles{
            if recentFile.mimeType != "audio" { continue }
            guard let url = URL(string: recentFile.fileURL) else { continue }
            
            playerItems.append(AVPlayerItem(url: url))
            urls.append(url)
            
            if recentFile == selectedFile{
                startIndex = playerItems.count - 1
            }
        }
        
        return (startIndex, playerItems, urls)
    }
    
    func getImageFiles(selectedFile: Recent) -> (startIndex: Int, images: [LightboxImage]){
        var images = [LightboxImage]()
        var startIndex = 0
        
        for recentFile in filteredRecentFiles{
            if recentFile.mimeType != "image" { continue }
            guard let url = URL(string: recentFile.fileURL) else { continue }
            
            images.append(LightboxImage(imageURL: url, text: recentFile.fileName))
            
            if recentFile == selectedFile {
                startIndex = images.count - 1
            }
        }
        
        return (startIndex, images)
    }
    
}
