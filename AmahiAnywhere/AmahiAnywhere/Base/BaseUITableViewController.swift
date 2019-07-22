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
        castButton.tintColor = UIColor.white
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
        checkCastConnection()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionManager.remove(self)
        NotificationCenter.default.removeObserver(self)
    }
}
