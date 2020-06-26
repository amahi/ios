//
//  ShareTableViewController.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 06/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit

class SharesViewController: BaseUIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet fileprivate var sharesCollectionView: UICollectionView!
    @IBOutlet var serverNameLabel: UILabel!
    
    internal var server: Server?
    private var shares: [ServerShare] = [ServerShare]()
    private var presenter: SharesPresenter!
    
    let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        if #available(iOS 13.0, *) {
            control.tintColor = .label

            control.attributedTitle = NSAttributedString(string: "Pull To Refresh", attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])
        } else {
            control.tintColor = .white
            control.attributedTitle = NSAttributedString(string: "Pull To Refresh", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            }

        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if server?.name != "Welcome to Amahi"{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .done, target: self, action: #selector(logOutTapped))
            
           
        }
        
        if #available(iOS 13.0, *) {
                       self.view.backgroundColor = UIColor.secondarySystemBackground
                       sharesCollectionView.backgroundColor = UIColor.secondarySystemBackground
            serverNameLabel.textColor = UIColor.label
                   } else {
                       self.view.backgroundColor = UIColor(hex: "1E2023")
                       sharesCollectionView.backgroundColor = UIColor(hex: "1E2023")
            serverNameLabel.textColor = UIColor.white
                   }

        removePinVC()
        sharesCollectionView.delegate = self
        sharesCollectionView.dataSource = self
        sharesCollectionView.addSubview(refreshControl)
        sharesCollectionView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
        
        serverNameLabel.text =  ServerApi.shared!.getServer()?.name
        
        presenter = SharesPresenter(self)
        presenter.loadServerRoute()
        
        NotificationCenter.default.addObserver(self, selector: #selector(expiredAuthTokenHDA), name: .HDATokenExpired, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitleConnection(title: "Shares")
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
    
    @objc func logOutTapped(){
        let serverName = ServerApi.shared!.getServer()?.name ?? ""
        LocalStorage.shared.delete(key: serverName)
        ServerApi.shared!.logoutHDA()
        navigationController?.popViewController(animated: true)
    }
    
    func removePinVC(){
        var navigationVCs = self.navigationController!.viewControllers
        for (index, vc) in navigationVCs.enumerated(){
            if vc is HDAPinAuthVC{
                navigationVCs.remove(at: index)
                self.navigationController!.viewControllers = navigationVCs
                break
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        sharesCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func updateNavigationBarBackgroundWhenLanTestFailed() {
        super.updateNavigationBarBackgroundWhenLanTestFailed()
        
        presenter.getShares()
    }
    
    @objc func handleRefresh(sender: UIRefreshControl) {
        presenter.getShares()
    }

    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SharesCollectionViewCell", for: indexPath) as? SharesCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if #available(iOS 13.0, *) {
            cell.titleLabel.textColor = UIColor.label
        } else {
            cell.titleLabel.textColor = UIColor.white
        }
        cell.titleLabel.text = shares[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let footerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as? FilesCollectionFooterView else {
            return UICollectionReusableView()
        }
    
        footerCell.titleLabel.text = "\(shares.count) Shares"
        if #available(iOS 13.0, *) {
            footerCell.titleLabel.textColor = UIColor.label
        } else {
            footerCell.titleLabel.textColor = UIColor.white
        }
        return footerCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        performSegue(withIdentifier: "files", sender: shares[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2, height: 140)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let filesViewController = segue.destination as? FilesViewController, let share = sender as? ServerShare{
            filesViewController.share = share
        }
    }
}

// Mark - Shares view implementations
extension SharesViewController: SharesView {
    
    func updateShares(shares: [ServerShare]) {
        self.shares = shares
        sharesCollectionView.reloadData()
    }
    
    func updateRefreshing(isRefreshing: Bool) {
        if isRefreshing {
            refreshControl.beginRefreshing()
        } else {
            refreshControl.endRefreshing()
        }
    }
}
