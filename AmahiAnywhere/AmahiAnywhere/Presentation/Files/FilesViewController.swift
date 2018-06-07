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
    
    // Mark - Server properties, will be set from presenting class
    public var directory: ServerFile?
    public var share: ServerShare!
    
    // Mark - TableView data properties
    private var serverFiles: [ServerFile] = [ServerFile]()
    private var filteredFiles: [ServerFile] = [ServerFile]()
    
    private var fileSort = FileSort.modifiedTime
    
    // Mark - UIKit properties
    @IBOutlet private var filesTableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var downloadProgressAlertController : UIAlertController?
    private var progressView: UIProgressView?
    private var docController: UIDocumentInteractionController?
    
    private var isAlertShowing = false
    private var presenter: FilesPresenter!
    
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
        fileSort = sender.selectedSegmentIndex == 0 ? FileSort.modifiedTime : FileSort.name
        presenter.reorderFiles(files: serverFiles, sortOrder: fileSort)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.filterFiles(searchText, files: serverFiles, sortOrder: fileSort)
    }
    
    // MARK: - Table view data source
    
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
    
    private func setupDownloadProgressIndicator() {
        downloadProgressAlertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView?.setProgress(0.0, animated: true)
        progressView?.frame = CGRect(x: 10, y: 100, width: 250, height: 2)
        downloadProgressAlertController?.view.addSubview(progressView!)
        let height:NSLayoutConstraint = NSLayoutConstraint(item: downloadProgressAlertController!.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 120)
        downloadProgressAlertController?.view.addConstraint(height);
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
    
    func dismissProgressIndicator(at url: URL, completion: @escaping () -> Void) {
        downloadProgressAlertController?.dismiss(animated: true, completion: {
            completion()
        })
        downloadProgressAlertController = nil
        progressView = nil
        isAlertShowing = false
    }
    
    func updateDownloadProgress(for row: Int, downloadJustStarted: Bool , progress: Float) {
        
        if downloadJustStarted {
            setupDownloadProgressIndicator()
            downloadProgressAlertController?.title = String(format: StringLiterals.DOWNLOADING_FILE, self.filteredFiles[row].name!)
        }
        
        if !isAlertShowing {
            self.isAlertShowing = true
            present(downloadProgressAlertController!, animated: true, completion: nil)
        }
        
        progressView?.setProgress(progress, animated: true)
    }
    
    func shareFile(at url: URL) {
        let linkToShare = [url]
        
        let activityController = UIActivityViewController(activityItems: linkToShare, applicationActivities: nil)
        
        self.present(activityController, animated: true, completion: nil)
    }
    
    func webViewOpenContent(at url: URL, mimeType: MimeType) {
        let webViewVc = self.viewController(viewControllerClass: WebViewController.self,
                                            from: StoryBoardIdentifiers.MAIN)
        webViewVc.url = url
        webViewVc.mimeType = mimeType
        self.navigationController?.pushViewController(webViewVc, animated: true)
    }
    
    func playMedia(at url: URL) {
        let videoPlayerVc = self.viewController(viewControllerClass: VideoPlayerViewController.self, from: StoryBoardIdentifiers.VIDEO_PLAYER)
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
    case modifiedTime
    case name
}
