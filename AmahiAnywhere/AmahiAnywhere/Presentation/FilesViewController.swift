//
//  FilesTableViewController.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 08/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit
import Lightbox

class FilesViewController: BaseUIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    public var directory: ServerFile?
    public var share: ServerShare!
    
    private var serverFiles: [ServerFile] = [ServerFile]()
    private var filteredFiles: [ServerFile] = [ServerFile]()
    private var presenter: FilesPresenter!
    var refreshControl: UIRefreshControl!
    
    private var fileSort = FileSort.ModifiedTime

    @IBOutlet var filesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = FilesPresenter(self)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        filesTableView.addSubview(refreshControl)
        
        self.navigationItem.title = getTitle()
        
        presenter.getFiles(share, directory: directory)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    // MARK: - File sorting and searching functionality
    
    @IBAction func onSortChange(_ sender: UISegmentedControl) {
        fileSort = sender.selectedSegmentIndex == 0 ? FileSort.ModifiedTime : FileSort.Name
        presenter.reorderFiles(files: serverFiles, sortOrder: fileSort)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.filterFiles(searchText, files: serverFiles)
    }

    // MARK: - Table view data source

//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFiles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let serverFile = filteredFiles[indexPath.row]
        if serverFile.isDirectory() {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServerDirectoryTableViewCell", for: indexPath)
            cell.textLabel?.text = serverFile.name
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServerFileTableViewCell", for: indexPath) as! ServerFileTableViewCell
            cell.fileNameLabel?.text = serverFile.name
            cell.fileSizeLabel?.text = serverFile.getFileSize()
            cell.lastModifiedLabel?.text = serverFile.getLastModifiedDate()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.handleFileOpening(fileIndex: indexPath.row, files: filteredFiles)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc: FilesViewController = segue.destination as! FilesViewController
        vc.share = self.share
        vc.directory = filteredFiles[(filesTableView.indexPathForSelectedRow?.row)!]
    }
}


// MARK: File View implementations

extension FilesViewController: FilesView {
    
    func playMedia(at url: URL) {
        let videoPlayerVc = self.viewController(viewControllerClass: VideoPlayerViewController.self, from: StoryBoardIdentifiers.MAIN)
        videoPlayerVc.mediaURL = url
        self.present(videoPlayerVc)
    }
    
    func present(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }
    
    func initFiles(_ files: [ServerFile]) {
        self.serverFiles = files
    }
    
    func updateFiles(_ files: [ServerFile]) {
        self.filteredFiles = files
        filesTableView.reloadData()
    }
    
    func updateRefreshing(isRefreshing: Bool) {
        if isRefreshing {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}

// MARK: - ServerFileTableViewCell

class ServerFileTableViewCell: UITableViewCell {

    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var lastModifiedLabel: UILabel!
}

enum FileSort {
    case ModifiedTime
    case Name
}
