//
//  ServerViewController.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/18/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit
import GoogleCast

class ServerViewController: BaseUIViewController {
    
    private var sessionManager: GCKSessionManager!
    private var castButton: GCKUICastButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sessionManager = GCKCastContext.sharedInstance().sessionManager
    }
    
    private var presenter: ServerPresenter!
    @IBOutlet var serversCollectionView: UICollectionView!
    @IBOutlet var availableLabel: UILabel!
    @IBOutlet var errorView: UIView!
    private var servers: [Server] = [Server]()
    
    let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        control.tintColor = .white
        control.attributedTitle = NSAttributedString(string: "Pull To Refresh", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionManager.add(self)
        serversCollectionView.delegate = self
        serversCollectionView.dataSource = self
        serversCollectionView.addSubview(refreshControl)
        serversCollectionView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
                
        presenter = ServerPresenter(self)
        presenter.fetchServers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        castButton = GCKUICastButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0),
                                                   width: CGFloat(24), height: CGFloat(24)))
        castButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
    }
    
    @objc func handleRefresh(sender: UIRefreshControl) {
        presenter.fetchServers()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        serversCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func showErrorView(){
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.errorView.alpha = 1.0
        }) { (_) in
            UIView.animate(withDuration: 1.0, delay: 2.0, options: .curveEaseOut, animations: {
                self.errorView.alpha = 0.0
            }, completion: nil)
        }
    }
    
    func hideErrorView(){
        UIView.animate(withDuration: 0.5) {
            self.errorView.alpha = 0.0
        }
        
        self.errorView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate?.isCastControlBarsEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionManager.remove(self)
    }
}

// Mark - CollectionView Delegates Implementations
extension ServerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return servers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.serverCell, for: indexPath) as? ServerCollectionViewCell else {
            return UICollectionViewCell()
        }

        let server = servers[indexPath.item]
        cell.setupData(server: server)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let server = servers[indexPath.item]
        if server.active{
            ServerApi.initialize(server: servers[indexPath.item])
            let sharesVc = viewController(viewControllerClass: SharesViewController.self, from: StoryBoardIdentifiers.main)
            navigationController?.pushViewController(sharesVc, animated: true)
        }else{
            showErrorView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((collectionView.frame.width-20-20) - 10) / 2
        
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width{
            return CGSize(width: width, height: collectionView.frame.height*0.30)
        }else{
            return CGSize(width: width, height: collectionView.frame.height*0.50)
        }
    }
    
}

// Mark - Server view implementations
extension ServerViewController: ServerView {
    
    func updateRefreshing(isRefreshing: Bool) {
        if isRefreshing {
            refreshControl.beginRefreshing()
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    func updateServerList(_ activeServers: [Server]) {
        self.servers = activeServers
        serversCollectionView.reloadData()
        
        var availableCounter = 0
        servers.forEach { (server) in
            availableCounter += server.active ? 1 : 0
        }
        if availableCounter > 1{
            availableLabel.text = "\(availableCounter) available HDAs"
        }else{
            availableLabel.text = "\(availableCounter) available HDA"
        }
    }
}
