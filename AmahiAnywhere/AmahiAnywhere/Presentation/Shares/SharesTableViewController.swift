//
//  ShareTableViewController.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 06/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit

class SharesTableViewController: BaseUITableViewController {
    
    @IBOutlet var sharesTableView: UITableView!
    
    internal var server: Server?
    private var shares: [ServerShare] = [ServerShare]()
    private var presenter: SharesPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = SharesPresenter(self)
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        
        presenter.loadServerRoute()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func handleRefresh(sender: UIRefreshControl) {
        presenter.getShares()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ServerApi.shared?.getServer()?.name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shares.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SharesTableViewCell", for: indexPath)
        cell.textLabel?.text = self.shares[indexPath.row].name
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc: FilesViewController = segue.destination as! FilesViewController
        vc.share = shares[(sharesTableView.indexPathForSelectedRow?.row)!]
    }
}

// Mark - Shares view implementations
extension SharesTableViewController: SharesView {
    
    func updateShares(shares: [ServerShare]) {
        self.shares = shares
        sharesTableView.reloadData()
    }
    
    func updateRefreshing(isRefreshing: Bool) {
        if isRefreshing {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}
