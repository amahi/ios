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
    private var servers: [Server] = [Server]()
    
    let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        if #available(iOS 13.0, *) {
            control.tintColor = .label
        } else {
            control.tintColor = .white
            
        }
        if #available(iOS 13.0, *) {

            control.attributedTitle = NSAttributedString(string: "Pull To Refresh", attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])

        } else {
            control.attributedTitle = NSAttributedString(string: "Pull To Refresh", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
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
        if #available(iOS 13.0, *) {
            castButton.tintColor = UIColor.label

            availableLabel.textColor = UIColor.label
            serversCollectionView.backgroundColor = UIColor.secondarySystemBackground
            self.view.backgroundColor = UIColor.secondarySystemBackground
            
        } else {
            castButton.tintColor = UIColor.white
            availableLabel.textColor = UIColor.white
            serversCollectionView.backgroundColor = UIColor(hex: "1E2023")
             self.view.backgroundColor = UIColor(hex: "1E2023")

        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
    }
    
    @objc func handleRefresh(sender: UIRefreshControl) {
        presenter.fetchServers()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        serversCollectionView.collectionViewLayout.invalidateLayout()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate?.isCastControlBarsEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionManager.remove(self)
    }
    
    @IBAction func recentsButtonPressed(_ sender: Any) {
        let recentsVC = self.instantiateViewController (withIdentifier: StoryBoardIdentifiers.recentsNavigationController, from: StoryBoardIdentifiers.main)
        self.present(recentsVC, animated: true, completion: nil)
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
            
            if server.name == "Welcome to Amahi"{
                showSharesVC(server: server)
            }else{
                if let authToken = LocalStorage.shared.getString(key: server.name ?? ""){
                    ServerApi.shared!.setAuthToken(token: authToken)
                    showSharesVC(server: server)
                }else{
                    showPinVC(server: server)
                }
            }
        }else{
            self.showStatusAlert(title: "The selected HDA is currently not available")
        }
        AppStoreReviewManager.requestReviewIfAppropriate()
    }
    
    func showPinVC(server: Server){
        let pinVC = viewController(viewControllerClass: HDAPinAuthVC.self, from: StoryBoardIdentifiers.main)
        pinVC.server = server
        navigationController?.pushViewController(pinVC, animated: true)

    }
    
    func showSharesVC(server: Server){
        let sharesVc = viewController(viewControllerClass: SharesViewController.self, from: StoryBoardIdentifiers.main)
        sharesVc.server = server
        navigationController?.pushViewController(sharesVc, animated: true)
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
        if #available(iOS 13.0, *) {
            availableLabel.textColor = UIColor.label
        } else {
            availableLabel.textColor = UIColor.white
            
        }
    }
}
