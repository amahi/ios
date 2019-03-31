//
//  ServerViewController.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/18/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit

class ServerViewController: BaseUITableViewController {
    
    private var presenter: ServerPresenter!
    @IBOutlet var serverTableView: UITableView!
    
    private var servers: [Server] = [Server]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        presenter = ServerPresenter(self)
        presenter.fetchServers()
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showDownloadsIconIfOfflineFileExists()
    }
    
    @objc func handleRefresh(sender: UIRefreshControl) {
        presenter.fetchServers()
    }

    @IBAction func settingButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: SegueIdentfiers.settings, sender: nil)
    }
}

// Mark - TableView Delegates Implementations
extension ServerViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.servers.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return StringLiterals.selectYourHDA
        } else {
            return StringLiterals.offline
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "ServerTableViewCell", for: indexPath)
        if indexPath.section == 0 {
            let server = self.servers[indexPath.row]
            cell.textLabel?.text = server.name
            cell.isUserInteractionEnabled = server.active
            cell.textLabel?.isEnabled = server.active
            cell.accessoryType = server.active ? .disclosureIndicator : .none
        } else {
            cell.textLabel?.text = StringLiterals.downloads
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            ServerApi.initialize(server: servers[indexPath.row])
            
            let sharesVc = viewController(viewControllerClass: SharesTableViewController.self,
                                          from: StoryBoardIdentifiers.main)
            navigationController?.pushViewController(sharesVc, animated: true)
        } else {
            let offlineFileVc = viewController(viewControllerClass: OfflineFilesTableViewController.self,
                                          from: StoryBoardIdentifiers.main)
            navigationController?.pushViewController(offlineFileVc, animated: true)
        }
    }
}

// Mark - Server view implementations
extension ServerViewController: ServerView {
    
    func updateRefreshing(isRefreshing: Bool) {
        if isRefreshing {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    func updateServerList(_ activeServers: [Server]) {
        self.servers = activeServers
        serverTableView.reloadData()
    }
}
