//
//  OfflineFilesViewController.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 27..
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import SwipeCellKit

class OfflineFilesViewController: BaseUIViewController{
    
    @IBOutlet var filesCollectionView: UICollectionView!
    @IBOutlet var sortButton: UIButton!
    @IBOutlet var layoutButton: UIButton!
    
    internal var docController: UIDocumentInteractionController?
    @objc internal var player: AVPlayer!
    
    internal var presenter: OfflineFilesPresenter!
    internal var fileSort = FileSort.name
    
    var searchController: UISearchController!
    var sortView: SortView!
    var sortBackgroundView: UIView!
    var layoutView: LayoutView!
    
    internal var offlineFiles = [OfflineFile]()
    internal var filteredFiles = FilteredOfflineFiles()
    
    let interactor = Interactor()
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the collection view
            // this runs once and fetches all the currently offline files (only happens once because of viewdidload)
            fetchedResultsController?.delegate = self
            executeSearch()
            // all old offline files have been fetched and stored in the array
            // create the filtered items array and create the sections
            if let offlineFiles = fetchedResultsController?.fetchedObjects as? [OfflineFile]{
                self.offlineFiles = offlineFiles
                organiseFilesSections(offlineFiles)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AmahiLogger.log("Active Downloads \(DownloadService.shared.activeDownloads)")
        presenter = OfflineFilesPresenter(self)
        self.navigationItem.title = StringLiterals.offline
        
        setupCollectionView()
        setupCoreData()
        setupSearchBar()
        
        if #available(iOS 13.0, *) {
                    self.view.backgroundColor = UIColor.secondarySystemBackground
          filesCollectionView.backgroundColor = UIColor.secondarySystemBackground
          sortButton.backgroundColor = UIColor.secondarySystemBackground
          sortButton.tintColor = UIColor.label
          sortButton.titleLabel?.textColor = UIColor.label
                    
         } else {
                    self.view.backgroundColor = UIColor(hex: "1E2023")
          filesCollectionView.backgroundColor = UIColor(hex: "1E2023")
                   
          sortButton.backgroundColor = UIColor(hex: "1E2023")
          sortButton.tintColor = UIColor.white
          sortButton.titleLabel?.textColor = UIColor.white
          }
        }
    
    func setupLayoutView(){
        layoutView = GlobalLayoutView.layoutView
        
        if layoutView == .listView{
            layoutButton.setImage(UIImage(named: "filesGridIcon"), for: .normal)
        }else{
            layoutButton.setImage(UIImage(named: "filesListIcon"), for: .normal)
        }
    }
    
    func setupCollectionView(){
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        filesCollectionView.addGestureRecognizer(longPressGesture)
        filesCollectionView.delegate = self
        filesCollectionView.dataSource = self
        filesCollectionView.allowsMultipleSelection = false
    }
    
    func setupCoreData(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OfflineFile")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func setupSearchBar(){
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
        self.navigationItem.rightBarButtonItem = searchButton
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        if #available(iOS 13.0, *) {
            searchController.searchBar.tintColor = .label
        } else {
            searchController.searchBar.tintColor = .white
        }
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [.foregroundColor: UIColor.white]
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        navigationController?.view.backgroundColor = self.view.backgroundColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController?.searchBar.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if layoutView != GlobalLayoutView.layoutView{
            setupLayoutView()
            filesCollectionView.reloadData()
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // Landscape to Portrait: width - > height, height -> width
        // Portrait to Landscape: width -> height, height -> width
        if sortBackgroundView != nil && sortView != nil{
            sortBackgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
            let height = size.height > size.width ? size.height * 0.3 : size.width * 0.25
            sortView.frame = CGRect(x: 0, y: UIScreen.main.bounds.width - height, width: size.width, height: height)
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
    
    @objc func searchTapped(){
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.rightBarButtonItem = nil
        searchController.isActive = true
    }
    
    
    @objc func handleLongPress(sender: UIGestureRecognizer){
        handleMoreMenu(touchPoint: sender.location(in: filesCollectionView))
    }
    
    func handleMoreMenu(touchPoint: CGPoint){
        if let indexPath = filesCollectionView.indexPathForItem(at: touchPoint){
            let offlineFile = filteredFiles.getFileFromIndexPath(indexPath)
            
            let delete = self.creatAlertAction(StringLiterals.delete, style: .destructive) { (action) in
                self.delete(file: offlineFile)
                }!
            
            let open = self.creatAlertAction(StringLiterals.open, style: .default) { (action) in
                self.presenter.handleOfflineFile(selectedFile: offlineFile, indexPath: indexPath, files: self.filteredFiles, from: self.filesCollectionView.cellForItem(at: indexPath))
                }!
            
            let share = self.creatAlertAction(StringLiterals.share, style: .default) { (action) in
                guard let url = FileManager.default.localFilePathInDownloads(for: offlineFile) else { return }
                self.shareFile(at: url, from: self.filesCollectionView.cellForItem(at: indexPath))
                }!
            
            let stop = self.creatAlertAction(StringLiterals.stopDownload, style: .default) { (action) in
                DownloadService.shared.cancelDownload(offlineFile)
                }!
            
            var actions = [UIAlertAction]()
            
            let state = offlineFile.stateEnum
            
            if state == .downloaded {
                if offlineFile.mimeType != .sharedFile {
                    actions.append(open)
                }
                actions.append(delete)
                actions.append(share)
            } else if state == .completedWithError {
                actions.append(delete)
            } else if state == .downloading {
                actions.append(stop)
            }
            
            let cancel = self.creatAlertAction(StringLiterals.cancel, style: .cancel, clicked: nil)!
            actions.append(cancel)
            
            self.createActionSheet(title: offlineFile.name,
                                   message: StringLiterals.chooseOne,
                                   ltrActions: actions,
                                   preferredActionPosition: 0,
                                   sender: filesCollectionView.cellForItem(at: indexPath))
        }
    }
    
    @objc func moreButtonTapped(sender: UIButton){
        let bounds = sender.convert(sender.bounds, to: filesCollectionView)
        handleMoreMenu(touchPoint: bounds.origin)
    }
    
    func delete(file offlineFile: OfflineFile) {
        // Delete file in downloads directory
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: fileManager.localFilePathInDownloads(for: offlineFile)!)
        } catch let error {
            AmahiLogger.log("Couldn't Delete file from Downloads \(error.localizedDescription)")
        }
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        // Delete Offline File from core date and persist new changes immediately
        stack.context.delete(offlineFile)
        try? stack.saveContext()
        AmahiLogger.log("File was deleted from Downloads")
    }
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                AmahiLogger.log("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }
    
    @IBAction func layoutButtonTapped(_ sender: Any) {
        GlobalLayoutView.switchLayoutMode()
        setupLayoutView()
        
        filesCollectionView.reloadData()
    }
    
    @IBAction func sortingTapped(_ sender: UIButton){
        showSortViews()
    }
    
    func showSortViews(){
        sortBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        sortBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        sortBackgroundView.isHidden = true
        sortBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSortView)))
        
        let height = self.view.frame.height > self.view.frame.width ? self.view.frame.height * 0.3 : self.view.frame.width * 0.25
        sortView = SortView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: height))
        sortView.selectedFilter = self.fileSort
        sortView.sortViewDelegate = self
        sortView.serverFilesMode = false
        sortView.tableView.reloadData()
        
        self.view.window?.addSubview(sortBackgroundView)
        self.view.window?.addSubview(sortView)
        
        UIView.animate(withDuration: 0.3) {
            self.sortBackgroundView.isHidden = false
            self.sortView.frame.origin.y = UIScreen.main.bounds.height - (height)
        }
    }
}

extension OfflineFilesViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        if type == .insert{
            if let file = anObject as? OfflineFile {
                offlineFiles.append(file)
                organiseFilesSections(offlineFiles)
            }
        }else if type == .update, let file = anObject as? OfflineFile{
            if let updatedIndexPath = filteredFiles.getIndexPathFromFile(file: file){
                if let cell = filesCollectionView.cellForItem(at: updatedIndexPath) as? DownloadsListCollectionCell{
                    cell.updateProgress(offlineFile: file)
                }else if let cell = filesCollectionView.cellForItem(at: updatedIndexPath) as? DownloadsGridCollectionCell{
                    cell.updateProgress(offlineFile: file)
                }
            }
        }else if type == .delete, let file = anObject as? OfflineFile, let deletedIndex = offlineFiles.index(of: file){
            offlineFiles.remove(at: deletedIndex)
            organiseFilesSections(offlineFiles)
            NotificationCenter.default.post(name: .OfflineFileDeleted, object: file, userInfo: ["loadOfflineFiles": true])
        }
    }
}

extension OfflineFilesViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}




