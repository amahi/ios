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
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
    }
    
    @objc func handleRefresh(sender: UIRefreshControl) {
        presenter.fetchServers()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.servers.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select your HDA"
    }
    
    @IBAction func settingButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: SegueIdentfiers.SETTING, sender: nil)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "ServerTableViewCell", for: indexPath)
        let server = self.servers[indexPath.row]
        cell.textLabel?.text = server.name
        cell.isUserInteractionEnabled = server.active
        cell.textLabel?.isEnabled = server.active
        cell.accessoryType = server.active ? .disclosureIndicator : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ServerApi.initialize(server: servers[indexPath.row])
    }
}

extension ServerViewController {
    
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
