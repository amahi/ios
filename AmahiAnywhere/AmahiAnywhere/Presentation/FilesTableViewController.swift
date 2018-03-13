//
//  FilesTableViewController.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 08/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit
import Lightbox

class FilesTableViewController: BaseUITableViewController {
    
    public var directory: ServerFile?
    public var share: ServerShare!
    
    private var serverFiles: [ServerFile] = [ServerFile]()
    private var presenter: FilesPresenter!

    @IBOutlet var filesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = FilesPresenter(self)
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        
        presenter.getFiles(share, directory: directory)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func handleRefresh(sender: UIRefreshControl) {
        presenter.getFiles(share, directory: directory)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if directory != nil {
            return directory?.name
        }
        return share.name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverFiles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let serverFile = serverFiles[indexPath.row]
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.handleFileOpening(fileIndex: indexPath.row, files: serverFiles)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc: FilesTableViewController = segue.destination as! FilesTableViewController
        vc.share = self.share
        vc.directory = serverFiles[(filesTableView.indexPathForSelectedRow?.row)!]
    }
}


// MARK: File View implementations

extension FilesTableViewController: FilesView {
    
    func playMedia(at url: URL) {
        let videoPlayerVc = self.viewController(viewControllerClass: VideoPlayerViewController.self,
                                                from: StoryBoardIdentifiers.MAIN)
        videoPlayerVc.mediaURL = url
        self.present(videoPlayerVc)
    }
    
    func present(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }
    
    func updateFiles(files: [ServerFile]) {
        self.serverFiles = files
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
