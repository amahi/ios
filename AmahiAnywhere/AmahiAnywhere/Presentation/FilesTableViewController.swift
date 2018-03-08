//
//  FilesTableViewController.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 08/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerFilesTableViewCell", for: indexPath) as! ServerFileTableViewCell
        let serverFile = serverFiles[indexPath.row]
        cell.fileNameLabel?.text = serverFile.name
        if serverFile.isDirectory() {
            cell.accessoryType = .disclosureIndicator
            cell.fileSizeLabel?.isHidden = true
            cell.lastModifiedLabel?.isHidden = true
        } else {
            cell.accessoryType = .none
            cell.fileSizeLabel?.text = serverFile.getFileSize()
            cell.lastModifiedLabel?.text = serverFile.getLastModifiedDate()
        }
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc: FilesTableViewController = segue.destination as! FilesTableViewController
        vc.share = self.share
        vc.directory = serverFiles[(filesTableView.indexPathForSelectedRow?.row)!]
    }

}

extension FilesTableViewController: FilesView {
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





