//
//  BaseUITableViewController.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 06/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit
import GoogleCast

class BaseUITableViewController: UITableViewController, GCKSessionManagerListener, GCKRequestDelegate {
    
    private var castButton: GCKUICastButton!
    private var sessionManager: GCKSessionManager!
    private var queueButton: UIBarButtonItem!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sessionManager = GCKCastContext.sharedInstance().sessionManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNavigationBarBackgroundAccordingToCurrentConnectionMode()
        addActiveDownloadObservers()
        addLanTestObservers()
        
        castButton = GCKUICastButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0),
                                                   width: CGFloat(24), height: CGFloat(24)))
        if #available(iOS 13.0, *) {
            castButton.tintColor = UIColor.secondarySystemBackground
        } else {
            castButton.tintColor = UIColor.white
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
        
        queueButton = UIBarButtonItem(image: UIImage(named: "queueIcon"),
                                      style: .plain, target: self, action: #selector(didTapQueueButton))
        NotificationCenter.default.addObserver(self, selector: #selector(castDeviceDidChange),
                                               name: NSNotification.Name.gckCastStateDidChange,
                                               object: GCKCastContext.sharedInstance())
        checkCastConnection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTabBarStarted), name: .UpdateTabBarStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTabBarCompleted), name: .UpdateTabBarCompleted, object: nil)
        
        checkCastConnection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UpdateTabBarStarted, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UpdateTabBarCompleted, object: nil)
        
        sessionManager.remove(self)
    }
    
    @objc func updateTabBarCompleted(){
        if var downloadsTabCounter = Int(tabBarController?.tabBar.items?[1].badgeValue ?? "1"){
            downloadsTabCounter -= 1
            if downloadsTabCounter >= 1{
                tabBarController?.tabBar.items?[1].badgeValue = String(downloadsTabCounter)
            }else{
                tabBarController?.tabBar.items?[1].badgeValue = nil
            }
        }
    }
    
    @objc func updateTabBarStarted(){
        if var downloadsTabCounter = Int(tabBarController?.tabBar.items?[1].badgeValue ?? "0"){
            downloadsTabCounter += 1
            tabBarController?.tabBar.items?[1].badgeValue = String(downloadsTabCounter)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func castDeviceDidChange(_: Notification) {
        if GCKCastContext.sharedInstance().castState != .noDevicesAvailable {
            
            GCKCastContext.sharedInstance().presentCastInstructionsViewControllerOnce(with: castButton)
        }
    }
    
    @objc func didTapQueueButton(){
        let queueVC = self.instantiateViewController (withIdentifier: StoryBoardIdentifiers.navigationBarController, from: StoryBoardIdentifiers.main)
        self.present(queueVC, animated: true, completion: nil)
    }
    
    func setQueueButtonVisible(_ visible: Bool) {
        var barItems = navigationItem.rightBarButtonItems
        if barItems!.count > 2 {
            return
        }
        if !visible {
            let index = barItems?.index(of: queueButton)
            if index == 1 {
                barItems?.remove(at: 1)
            }
            navigationItem.rightBarButtonItems = barItems
        }
        else {
            if barItems!.count >= 2 {
                return
            }
            barItems?.append(queueButton)
            navigationItem.rightBarButtonItems = barItems
        }
    }
    
    func checkCastConnection(){
        if(self.sessionManager.currentSession != nil){
            setQueueButtonVisible(true)
        }
        else {
            setQueueButtonVisible(false)
        }
    }

}
