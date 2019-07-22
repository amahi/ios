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
        castButton.tintColor = UIColor.white
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
        }
        let queueVC = self.instantiateViewController (withIdentifier: StoryBoardIdentifiers.navigationBarController, from: StoryBoardIdentifiers.main)
        self.present(queueVC, animated: true, completion: nil)
    }
    
    func setQueueButtonVisible(_ visible: Bool) {
        var barItems = navigationItem.rightBarButtonItems
        if barItems!.count > 2 {
            return
        }
        if visible {
            if barItems!.count >= 2 {
                return
            }
            barItems?.append(queueButton)
            navigationItem.rightBarButtonItems = barItems
        } else if !visible {
            let index = barItems?.index(of: queueButton)
            if index == 1 {
                barItems?.remove(at: 1)
            }
            navigationItem.rightBarButtonItems = barItems
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
        
        appDelegate?.isCastControlBarsEnabled = true
        checkCastConnection()
        updateNavigationBarBackgroundAccordingToCurrentConnectionMode()
        addActiveDownloadObservers()
        addLanTestObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionManager.remove(self)
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
