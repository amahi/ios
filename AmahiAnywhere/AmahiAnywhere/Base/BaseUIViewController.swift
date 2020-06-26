//
//  BaseUIViewController.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/17/18.
//  Copyright © 2018 Amahi. All rights reserved.


import UIKit
import Foundation
import GoogleCast

class BaseUIViewController: UIViewController, GCKSessionManagerListener, GCKRequestDelegate {
    
    private var sessionManager: GCKSessionManager!
    private var castButton: GCKUICastButton!
    private var queueButton: UIBarButtonItem!
    
    // Timer to check if cast session is already active when the view loads
    var timer = Timer()
    var secondsCounter = 0
    var castConnected = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sessionManager = GCKCastContext.sharedInstance().sessionManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionManager.add(self)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
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
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
        scheduledTimerWithTimeInterval()
    }

    @objc func didTapQueueButton(){
        if self.sessionManager.currentSession == nil {
            setQueueButtonVisible(false)
            return
        }
        
        let queueVC = self.instantiateViewController (withIdentifier: StoryBoardIdentifiers.navigationBarController, from: StoryBoardIdentifiers.main)
        self.present(queueVC, animated: true, completion: nil)
    }
    
    func setQueueButtonVisible(_ visible: Bool) {
        var barItems = navigationItem.rightBarButtonItems

        if visible {
            if barItems != nil && barItems!.contains(queueButton){
                return
            }
            barItems?.append(queueButton)
            navigationItem.rightBarButtonItems = barItems
        } else{
            if let index = barItems?.index(of: queueButton){
                navigationItem.rightBarButtonItems?.remove(at: index)
            }
        }
    }
    
    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    func checkCastConnection(){
        if(self.sessionManager.currentSession != nil){
            setQueueButtonVisible(true)
        }
        else {
            setQueueButtonVisible(false)
        }
    }
    
    @objc func updateCounting(){
        secondsCounter = secondsCounter + 1
        if secondsCounter == 3 {
            checkCastConnection()
            timer.invalidate()
        }
    }
    
    @objc func deviceOrientationDidChange(_: Notification) {
        print("Orientation changed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTabBarStarted), name: .UpdateTabBarStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTabBarCompleted), name: .UpdateTabBarCompleted, object: nil)
        
        appDelegate?.isCastControlBarsEnabled = true
        checkCastConnection()
        updateNavigationBarBackgroundAccordingToCurrentConnectionMode()
        addActiveDownloadObservers()
        addLanTestObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UpdateTabBarStarted, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UpdateTabBarCompleted, object: nil)
        
        sessionManager.remove(self)
    }
    
    @objc func updateTabBarCompleted(){
        if var downloadsTabCounter = Int(tabBarController?.tabBar.items?[2].badgeValue ?? "1"){
            downloadsTabCounter -= 1
            if downloadsTabCounter >= 1{
                tabBarController?.tabBar.items?[2].badgeValue = String(downloadsTabCounter)
            }else{
                tabBarController?.tabBar.items?[2].badgeValue = nil
            }
        }
    }
    
    @objc func updateTabBarStarted(){
        if var downloadsTabCounter = Int(tabBarController?.tabBar.items?[2].badgeValue ?? "0"){
            downloadsTabCounter += 1
            tabBarController?.tabBar.items?[2].badgeValue = String(downloadsTabCounter)
        }
    }
        
    deinit {
         NotificationCenter.default.removeObserver(self)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - GCKSessionManagerListener
    
    func sessionManager(_: GCKSessionManager, didStart session: GCKSession) {
        print("MediaViewController: sessionManager didStartSession \(session)")
    }
    
    func sessionManager(_: GCKSessionManager, didResumeSession session: GCKSession) {
        print("MediaViewController: sessionManager didResumeSession \(session)")
    }
    
    func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?) {
        print("session ended with error: \(String(describing: error))")
        let message = "The Casting session has ended.\n\(String(describing: error))"
        if let window = appDelegate?.window {
            Toast.displayMessage(message, for: 3, in: window)
        }
    }
    
    func sessionManager(_: GCKSessionManager, didFailToStartSessionWithError error: Error?) {
        if let error = error {
            showAlert(withTitle: "Failed to start a session", message: error.localizedDescription)
        }
    }
    
    func sessionManager(_: GCKSessionManager,
                        didFailToResumeSession _: GCKSession, withError _: Error?) {
        if let window = UIApplication.shared.delegate?.window {
            Toast.displayMessage("The Casting session could not be resumed.", for: 3, in: window)
        }
        
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertView(title: title, message: message,
                                delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "")
        alert.show()
    }
    
    // MARK: - GCKRequestDelegate
    
    func requestDidComplete(_ request: GCKRequest) {
        print("request \(Int(request.requestID)) completed")
    }
    
    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        print("request \(Int(request.requestID)) failed with error \(error)")
    }
    
    func showStatusAlert(title: String, _ extraSpace: Bool = false){
        let statusView = UIView()
       // statusView.backgroundColor = UIColor(hex: "1E2023")
        if #available(iOS 13.0, *) {
            statusView.backgroundColor = UIColor.secondarySystemBackground
        } else {
            statusView.backgroundColor = UIColor(hex: "1E2023")
        }
        statusView.layer.cornerRadius = 8
        statusView.alpha = 1
        
        let label = UILabel()
        label.text = title
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
                label.textColor = .white
        }
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .center
        
        self.view.addSubview(statusView)
        statusView.addSubview(label)
        
        let bottomConstant: CGFloat = extraSpace ? 80 : 20
        
        statusView.setAnchors(top: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, topConstant: nil, leadingConstant: 20, trailingConstant: 20, bottomConstant: bottomConstant)
        statusView.setAnchorSize(width: nil, height: 50)
        
        label.setAnchors(top: statusView.topAnchor, leading: statusView.leadingAnchor, trailing: statusView.trailingAnchor, bottom: statusView.bottomAnchor, topConstant: 0, leadingConstant: 10, trailingConstant: 10, bottomConstant: 0)

        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            statusView.alpha = 1.0
        }) { (_) in
            UIView.animate(withDuration: 1.0, delay: 2.0, options: .curveEaseOut, animations: {
                statusView.alpha = 0.0
            }, completion: nil)
        }
    }
    
    func setNavigationTitleConnection(title: String){
        let connectionMode = ConnectionModeManager.shared.currentMode
        
        if connectionMode == ConnectionMode.auto {
            let isLocalInUse = ConnectionModeManager.shared.isLocalInUse()
            if isLocalInUse {
                navigationItem.titleView = nil
                navigationItem.title = title
            } else {
                navigationItem.setTitleWithRemoteIcon(title: title)
            }
        } else{
            if connectionMode == .local{
                navigationItem.titleView = nil
                navigationItem.title = title
            }else{
                navigationItem.setTitleWithRemoteIcon(title: title)
            }
        }
    }
    
}


extension BaseUIViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
}

extension BaseUITableViewController{
    func showStatusAlert(title: String){
        let statusView = UIView()
       // statusView.backgroundColor = UIColor(hex: "1E2023")
        if #available(iOS 13.0, *) {

            statusView.backgroundColor = UIColor.secondarySystemBackground

        } else {
            statusView.backgroundColor = UIColor(hex: "1E2023")
            
        }
        statusView.layer.cornerRadius = 8
        statusView.alpha = 1
        
        let label = UILabel()
        label.text = title
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .white
        }
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .center
        
        self.view.addSubview(statusView)
        statusView.addSubview(label)
        
        statusView.setAnchors(top: nil, leading: nil, trailing: nil, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, topConstant: nil, leadingConstant: nil, trailingConstant: nil, bottomConstant: 20)
        statusView.setAnchorSize(width: self.tableView.frame.width-40, height: 50)
        statusView.center(toVertically: nil, toHorizontally: self.tableView)
        
        label.setAnchors(top: statusView.topAnchor, leading: statusView.leadingAnchor, trailing: statusView.trailingAnchor, bottom: statusView.bottomAnchor, topConstant: 0, leadingConstant: 10, trailingConstant: 10, bottomConstant: 0)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            statusView.alpha = 1.0
        }) { (_) in
            UIView.animate(withDuration: 1.0, delay: 2.0, options: .curveEaseOut, animations: {
                statusView.alpha = 0.0
            }, completion: nil)
        }
    }
}
