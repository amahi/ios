//
//  FilesTableViewController.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 08/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit
import Lightbox
import AVFoundation
import GoogleCast
import Floaty

class FilesViewController: BaseUIViewController, GCKRemoteMediaClientListener {
    
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
    
    // Mark - Server properties, will be set from presenting class
    public var directory: ServerFile?
    public var share: ServerShare!
    
    private var castButton: GCKUICastButton!
    
    // Mark - TableView data properties
    internal var serverFiles = [ServerFile]()
    internal var filteredFiles = FilteredServerFiles()
    
    internal var fileSort: FileSort!
    
    /*
     KVO context used to differentiate KVO callbacks for this class versus other
     classes in its class hierarchy.
     */
    internal var playerKVOContext = 0
    
    // Mark - UIKit properties
    internal var refreshControl: UIRefreshControl!
    internal var downloadProgressAlertController : UIAlertController?
    internal var progressView: UIProgressView?
    internal var downloadImageView: UIImageView?
    internal var downloadTitleLabel: UILabel?
    internal var docController: UIDocumentInteractionController?
    
    @objc internal var player: AVPlayer!
    
    internal var isAlertShowing = false
    internal var presenter: FilesPresenter!
    
    @IBOutlet var filesCollectionView: UICollectionView!
    var searchController: UISearchController!
    var sortView: SortView!
    var sortBackgroundView: UIView!
    
    @IBOutlet var sortButton: UIButton!
    @IBOutlet var layoutButton: UIButton!
    var layoutView: LayoutView!
    
    @IBOutlet var floaty: Floaty!
    @IBOutlet var floatyBottomConstraint: NSLayoutConstraint!
    var imagePicker: UIImagePickerController!
    
    let interactor = Interactor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
        presenter = FilesPresenter(self)
        setupFloaty()
        setupLayoutView()
        setupRefreshControl()
        setupSearchBar()
        setupCollectionView()
        updateFileSort(sortingMethod: GlobalFileSort.fileSort)
        presenter.getFiles(share, directory: directory)
        
        NotificationCenter.default.addObserver(self, selector: #selector(expiredAuthTokenHDA), name: .HDATokenExpired, object: nil)
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.secondarySystemBackground
            filesCollectionView.backgroundColor = UIColor.secondarySystemBackground
            sortButton.titleLabel?.textColor = UIColor.label
            sortButton.tintColor = UIColor.label
            floaty.tintColor = UIColor.label
        } else {
            self.view.backgroundColor = UIColor(hex: "1E2023")
            filesCollectionView.backgroundColor = UIColor(hex: "1E2023")
            sortButton.titleLabel?.textColor = UIColor.white
            sortButton.tintColor = UIColor.white
            floaty.tintColor = UIColor.white
        }
        
    }
    
    func setupImagePicker(){
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    func setupFloaty(){
        
        floaty.addItem("Upload an image", icon: UIImage(named: "camera")) { (item) in
            self.uploadImageTapped()
        }
    }
    
    @objc func expiredAuthTokenHDA(){
        let alertVC = UIAlertController(title: "Session Expired", message: "Your session expired or was lost. Please login again.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let serverName = ServerApi.shared?.getServer()?.name{
                LocalStorage.shared.delete(key: serverName)
            }
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func uploadImageTapped(){
        let alertVC = UIAlertController(title: "Select your source", message: nil, preferredStyle: .actionSheet)
        
        alertVC.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alertVC.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func setupLayoutView(){
        layoutView = GlobalLayoutView.layoutView
        
        if layoutView == .listView{
            layoutButton.setImage(UIImage(named: "filesGridIcon"), for: .normal)
        }else{
            layoutButton.setImage(UIImage(named: "filesListIcon"), for: .normal)
        }
    }
    
    func setupRefreshControl(){
        refreshControl = UIRefreshControl()
        if #available(iOS 13.0, *) {
            refreshControl.tintColor = .label
        } else {
            refreshControl.tintColor = .white
        }
        if #available(iOS 13.0, *) {
            refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh", attributes: [.foregroundColor: UIColor.label])
        } else {
            refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh", attributes: [.foregroundColor: UIColor.white])
        }
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        filesCollectionView.addSubview(refreshControl)
    }
    
    func setupNavigationItem(){
        let title = getTitle() ?? "Files"
        setNavigationTitleConnection(title: title)
        self.navigationItem.title = getTitle()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: getTitle(), style: .plain, target: nil, action: nil)
    }
    
    func setupCollectionView(){
        filesCollectionView.delegate = self
        filesCollectionView.dataSource = self
        filesCollectionView.allowsMultipleSelection = false
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        filesCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationItem()
        
        if fileSort != GlobalFileSort.fileSort || layoutView != GlobalLayoutView.layoutView{
            setupLayoutView()
            updateFileSort(sortingMethod: GlobalFileSort.fileSort, refreshCollectionView: true)
        }
        
        presenter.loadOfflineFiles()
        let hasConnectedSession: Bool = (sessionManager.hasConnectedSession())
        if hasConnectedSession, (playbackMode != .remote) {
            
        } else if sessionManager.currentSession == nil, (playbackMode != .local) {
        }
        sessionManager.add(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if imagePicker == nil{
            setupImagePicker()
        }
    }
    
    func setupNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(offlineFileUpdated), name: .DownloadCompletedSuccessfully, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlineFileUpdated), name: .OfflineFileDeleted, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(offlineFileUpdated(_:)), name: .DownloadStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlineFileUpdated(_:)), name: .DownloadCancelled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlineFileUpdated(_:)), name: .DownloadCompletedWithError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(miniControllerOn), name: .ShowMiniController, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(miniControllerOff), name: .HideMiniController, object: nil)
    }
    
    @objc func miniControllerOn(){
        floatyBottomConstraint.constant = 80
    }
    
    @objc func miniControllerOff(){
        floatyBottomConstraint.constant = 20
    }
    
    @objc func offlineFileUpdated(_ notification: Notification){
        
        if notification.userInfo?["loadOfflineFiles"] != nil{
            // If offline files have changed - an offline file was deleted
            presenter.loadOfflineFiles()
        }
        
        if let offlineFile = notification.object as? OfflineFile, let indexPath = OfflineFileIndexes.offlineFilesIndexPaths[offlineFile] {
            if indexPath.section < filesCollectionView.numberOfSections && indexPath.item < filesCollectionView.numberOfItems(inSection: indexPath.section){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    UIView.performWithoutAnimation {
                        self.filesCollectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        }
    }
    
    func removeOfflineFile(indexPath: IndexPath){
        if let offlineFile = OfflineFileIndexes.indexPathsForOfflineFiles[indexPath]{
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
            NotificationCenter.default.post(name: .OfflineFileDeleted, object: offlineFile, userInfo: ["loadOfflineFiles": true])
        }
    }
    
    func setupSearchBar(){
        addSearchBarButton()
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        if #available(iOS 13.0, *) {
            searchController.searchBar.tintColor = .label
        } else {
            searchController.searchBar.tintColor = .white
        }
        if #available(iOS 13.0, *) {
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [.foregroundColor: UIColor.systemGray6]
        } else {
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [.foregroundColor: UIColor.white]
        }
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        
        definesPresentationContext = true
        navigationController?.view.backgroundColor = self.view.backgroundColor
    }
    
    @objc func searchTapped(){
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        searchController.isActive = true
        
        removeSearchBarButton()
    }
    
    func addSearchBarButton(){
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
        if self.navigationItem.rightBarButtonItems != nil && self.navigationItem.rightBarButtonItems!.count > 0{
            self.navigationItem.rightBarButtonItems?.insert(searchButton, at: 0)
        }else{
            self.navigationItem.rightBarButtonItem = searchButton
        }
    }
    
    func removeSearchBarButton(){
        if self.navigationItem.rightBarButtonItems?.count == 1{
            self.navigationItem.rightBarButtonItem = nil
        }else{
            self.navigationItem.rightBarButtonItems?.remove(at: 0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.searchBar.resignFirstResponder()
        sessionManager.remove(self)
    }
    
    @objc func moreButtonTapped(sender: UIButton){
        let bounds = sender.convert(sender.bounds, to: filesCollectionView)
        handleMoreMenu(touchPoint: bounds.origin)
    }
    
    func handleMoreMenu(touchPoint: CGPoint){
        if let indexPath = filesCollectionView.indexPathForItem(at: touchPoint) {
            
            let fileShare = self.share!
            
            let file = self.filteredFiles.getFileFromIndexPath(indexPath)
            
            if file.isDirectory { return }
            
            let download = self.creatAlertAction(StringLiterals.download, style: .default) { (action) in
                self.presenter.makeFileAvailableOffline(file, indexPath)
                }!
            let state = presenter.checkFileOfflineState(file)
            
            let share = self.creatAlertAction(StringLiterals.share, style: .default) { (action) in
                self.presenter.shareFile(file, fileIndex: indexPath.row, section: indexPath.section,
                                         from: self.filesCollectionView.cellForItem(at: indexPath))
                }!
            
            let removeOffline = self.creatAlertAction(StringLiterals.removeOfflineMessage, style: .default) { (action) in
                    self.removeOfflineFile(indexPath: indexPath)
                }!
            
            let delete = self.creatAlertAction(StringLiterals.delete, style: .destructive) { (action) in
                self.deleteFile(file)
                }!
            
            let stop = self.creatAlertAction(StringLiterals.stopDownload, style: .default) { (action) in
                    if let offlineFile = OfflineFileIndexes.indexPathsForOfflineFiles[indexPath]{
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
            
            actions.append(delete)
            
            let cancel = self.creatAlertAction(StringLiterals.cancel, style: .cancel, clicked: nil)!
            actions.append(cancel)
            
            self.createActionSheet(title: file.name,
                                   message: nil,
                                   ltrActions: actions,
                                   preferredActionPosition: 0,
                                   sender: filesCollectionView.cellForItem(at: indexPath))
        }
    }
    
    func deleteFile(_ file: ServerFile) {
        let deleteAlert = UIAlertController(title: "Are you sure?", message: "The selected file will be permanently deleted.", preferredStyle: UIAlertController.Style.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            return
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            self.deleteFiles(file, self.share, directory: self.directory)
            self.presenter.getFiles(self.share, directory: self.directory)
        }))
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    func deleteFiles(_ file: ServerFile, _ share: ServerShare, directory: ServerFile? = nil) {
        ServerApi.shared!.deleteFiles(file: file, share: share, directory: directory) { (success) in
            if success{
                self.showStatusAlert(title: "File was successfully deleted", true)
            }else{
                self.showStatusAlert(title: "An error occured while deleting the file", true)
            }
        }
    }
    
    @objc func handleLongPress(sender: UIGestureRecognizer) {
        handleMoreMenu(touchPoint: sender.location(in: filesCollectionView))
    }
    
    @objc func userClickMenu(sender: UIGestureRecognizer) {
        handleLongPress(sender: sender)
    }
    
    @objc func handleRefresh(sender: UIRefreshControl) {
        presenter.getFiles(share, directory: directory)
    }
    
    func getTitle() -> String? {
        if directory != nil {
            return directory!.name
        }
        return share!.name
    }
    
    internal func setupDownloadProgressIndicator() {
        downloadProgressAlertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        downloadProgressAlertController?.view.setAnchorSize(width: nil, height: 190)
        
        downloadTitleLabel = UILabel()
        downloadTitleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        downloadTitleLabel?.numberOfLines = 2
        downloadTitleLabel?.textAlignment = .center
        if #available(iOS 13.0, *) {
            downloadTitleLabel?.textColor = UIColor.label
        } else {
            downloadTitleLabel?.textColor = UIColor.white
        }
        
        downloadProgressAlertController?.view.addSubview(downloadTitleLabel!)
        downloadImageView = UIImageView(image: nil)
        downloadImageView?.contentMode = .scaleAspectFit
        downloadImageView?.setAnchorSize(width: 80, height: 80)
        
        progressView = UIProgressView(progressViewStyle: .bar)
        if #available(iOS 13.0, *) {
            progressView?.trackTintColor = .label
        } else {
            progressView?.trackTintColor = .white
        }

        
        progressView?.setProgress(0.0, animated: true)
        progressView?.setAnchorSize(width: nil, height: 2)
    
        let stackView = UIStackView(arrangedSubviews: [downloadTitleLabel!, downloadImageView!, progressView!])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.alignment = .fill
        
        downloadProgressAlertController?.view.addSubview(stackView)
        stackView.setAnchors(top: downloadProgressAlertController?.view.topAnchor, leading: downloadProgressAlertController?.view.leadingAnchor, trailing: downloadProgressAlertController?.view.trailingAnchor, bottom: downloadProgressAlertController?.view.bottomAnchor, topConstant: 20, leadingConstant: 20, trailingConstant: 20, bottomConstant: 20)
    }
    
    // MARK: - Navigation
    
    func handleFolderOpening(serverFile: ServerFile){
        let vc = UIStoryboard(name: StoryBoardIdentifiers.main, bundle: nil).instantiateViewController(withIdentifier: StoryBoardIdentifiers.filesViewController) as! FilesViewController
        vc.share = self.share
        vc.directory = serverFile
        vc.fileSort = fileSort
        vc.layoutView = layoutView
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func sortingTapped(_ sender: UIButton){
        showSortViews()
    }
    
    func showSortViews(){
        sortBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        if #available(iOS 13.0, *) {
            sortBackgroundView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.6)
        } else {
            sortBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }
        sortBackgroundView.isHidden = true
        sortBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSortView)))
        
        let height = self.view.frame.height > self.view.frame.width ? self.view.frame.height * 0.4 : self.view.frame.width * 0.3
        sortView = SortView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: height))
        sortView.selectedFilter = self.fileSort
        sortView.sortViewDelegate = self
        sortView.tableView.reloadData()
        
        self.view.window?.addSubview(sortBackgroundView)
        self.view.window?.addSubview(sortView)
    
        UIView.animate(withDuration: 0.3) {
            self.sortBackgroundView.isHidden = false
            self.sortView.frame.origin.y = UIScreen.main.bounds.height - (height)
        }
    }
    
    @objc func dismissSortView(){
        UIView.animate(withDuration: 0.3, animations: {
            self.sortBackgroundView.isHidden = true
            self.sortView.frame.origin.y = UIScreen.main.bounds.height
        }) { (_) in
            self.sortBackgroundView.removeFromSuperview()
            self.sortView.removeFromSuperview()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // Landscape to Portrait: width - > height, height -> width
        // Portrait to Landscape: width -> height, height -> width
        if sortBackgroundView != nil && sortView != nil{
            sortBackgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
            let height = size.height > size.width ? size.height * 0.4 : size.width * 0.3
            sortView.frame = CGRect(x: 0, y: UIScreen.main.bounds.width - height, width: size.width, height: height)
        }
    }
    
    @IBAction func layoutButtonTapped(_ sender: Any) {
        GlobalLayoutView.switchLayoutMode()
        setupLayoutView()
        filesCollectionView.reloadData()
    }
    
    func updateFileSort(sortingMethod: FileSort, refreshCollectionView: Bool = false){
        UIView.performWithoutAnimation {
            self.sortButton.setTitle(sortingMethod.rawValue, for: .normal)
            self.sortButton.layoutIfNeeded()
            if #available(iOS 13.0, *) {
                self.sortButton.tintColor = UIColor.label
            } else {
                self.sortButton.tintColor = UIColor.white
            }
        }
        
        GlobalFileSort.fileSort = sortingMethod
        fileSort = sortingMethod
        
        if refreshCollectionView{
            updateFiles(serverFiles)
        }
    }
    
}

extension FilesViewController: SortViewDelegate{
    func sortingSelected(sortingMethod: FileSort) {
        dismissSortView()
        
        if sortingMethod == fileSort {
            return
        }
        
        updateFileSort(sortingMethod: sortingMethod, refreshCollectionView: true)
    }
}

extension FilesViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let _ = info[.editedImage] as? UIImage else {
            return
        }
    }
}

extension FilesViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
