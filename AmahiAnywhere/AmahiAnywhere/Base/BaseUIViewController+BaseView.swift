//
//  BaseUIViewController+BaseView.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/17/18.
//  Copyright © 2018 Amahi. All rights reserved.


import UIKit
import MBProgressHUD

// Mark - Generic View Setup
extension BaseUIViewController: BaseView {
    
    func showLoading() {
        showProgressIndicator(withMessage: StringLiterals.pleaseWait)
    }
    
    func showLoading(withMessage text: String) {
        showProgressIndicator(withMessage: text)
    }
    
    func dismissLoading() {
        dismissProgressIndicator()
    }
    
    func showError(title: String, message text: String) {
        createErrorDialog(title: title, message: text)
    }
    
    func showError(message text: String) {
        createErrorDialog(message: text)
    }
    
    func isNetworkConnected() {}
}


// Mark - Generic Table View Setup
extension BaseUITableViewController: BaseView {
    
    func showLoading() {
        showProgressIndicator(withMessage: StringLiterals.pleaseWait)
    }
    
    func showLoading(withMessage text: String) {
        showProgressIndicator(withMessage: text)
    }
    
    func dismissLoading() {
        dismissProgressIndicator()
    }
    
    func showError(title: String, message text: String) {
        createErrorDialog(title: title, message: text)
    }
    
    func showError(message text: String) {
        createErrorDialog(message: text)
    }
    
    func isNetworkConnected() {}
}


// Mark - Common View Actions

extension UIViewController {
    
    @objc func updateNavigationBarBackgroundAccordingToCurrentConnectionMode() {
        if LocalStorage.shared.userConnectionPreference != .auto {
            let connectionMode = LocalStorage.shared.userConnectionPreference
            let color = connectionMode == .remote ? UIColor.remoteIndicatorBrown : UIColor.localIndicatorBlack
            self.navigationController?.navigationBar.backgroundColor = color

        }
    }
    
    @objc func updateNavigationBarBackgroundWhenLanTestPassed() {
        self.navigationController?.navigationBar.backgroundColor = UIColor.localIndicatorBlack
    }
    
    @objc func updateNavigationBarBackgroundWhenLanTestFailed() {
        self.navigationController?.navigationBar.backgroundColor = UIColor.remoteIndicatorBrown
    }
    
    func showDownloadsIconIfOfflineFileExists() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        if !stack.isDownloadsEmpty {
            let rightButton = UIBarButtonItem(image: UIImage(named: "cellphoneIcon"),
                                              style: .plain, target: self,
                                              action: #selector(userClickedDownloadsIcon))
            
            if DownloadService.shared.activeDownloads.isEmpty {
                rightButton.tintColor = UIColor.white
            } else {
                rightButton.tintColor = UIColor.softYellow
            }
            navigationItem.rightBarButtonItem = rightButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc func userClickedDownloadsIcon() {
        let offlineFileVc = viewController(viewControllerClass: OfflineFilesTableViewController.self,
                                           from: StoryBoardIdentifiers.main)
        navigationController?.pushViewController(offlineFileVc, animated: true)
    }
    
    @objc func updateDownloadsIconOnDownloadStarted() {
        
        AmahiLogger.log("Active Downloads count \(DownloadService.shared.activeDownloads.count)")
        
        if navigationItem.rightBarButtonItem == nil {
            let rightButton = UIBarButtonItem(image: UIImage(named: "cellphoneIcon"),
                                              style: .plain, target: self,
                                              action: #selector(userClickedDownloadsIcon))
            navigationItem.rightBarButtonItem = rightButton
        }
        
        if DownloadService.shared.activeDownloads.isEmpty {
            navigationController?.viewControllers.forEach({ (controller) in                    controller.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            })
        } else {
            navigationController?.viewControllers.forEach({ (controller) in                    controller.navigationItem.rightBarButtonItem?.tintColor = UIColor.softYellow
            })
        }
    }
    
    @objc func updateDownloadsIconOnDownloadCompleted() {
        AmahiLogger.log("Active Downloads count \(DownloadService.shared.activeDownloads.count)")
        
        if DownloadService.shared.activeDownloads.isEmpty {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        } else {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.softYellow
        }
    }
    
    func addActiveDownloadObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDownloadsIconOnDownloadStarted),
                                               name: .DownloadStarted, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDownloadsIconOnDownloadCompleted),
                                               name: .DownloadCompletedSuccessfully, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateDownloadsIconOnDownloadCompleted),
                                               name: .DownloadCompletedWithError, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDownloadsIconOnDownloadCompleted),
                                               name: .DownloadCancelled, object: nil)
    }
    
    func addLanTestObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNavigationBarBackgroundWhenLanTestPassed),
                                               name: .LanTestPassed, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNavigationBarBackgroundWhenLanTestFailed),
                                               name: .LanTestFailed, object: nil)
    }
    
    class var storyboardID : String {
        return "\(self)"
    }
    
    func performSegue(identifier: String) {
        OperationQueue.main.addOperation {
            [weak self] in
            self?.performSegue(withIdentifier: identifier, sender: self);
        }
    }
    
    func instantiateViewController(withIdentifier id : String, from storyBoardName: String) -> UIViewController {
        // Get the Storyboard with id and Create View COntroller with parameter name -> storyBoardName
        let storyboard = UIStoryboard (name: storyBoardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: id)
        
        return vc
    }
    
    // Get the Storyboard with id and Create View COntroller with parameter name -> storyBoardName
    // Use the ViewController's name as the storyboard identifier to instantiate with this method
    func viewController<T: UIViewController>(viewControllerClass: T.Type,
                                             from storyBoardName: String) -> T {
        let storyboard = UIStoryboard (name: storyBoardName, bundle: nil)
        let storyBoardID = (viewControllerClass as UIViewController.Type).storyboardID
        
        return storyboard.instantiateViewController(withIdentifier: storyBoardID) as! T
    }
    
    func createErrorDialog(title: String! = "Oops!", message: String! = StringLiterals.genericNetworkError) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert);
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil);
        alertController.addAction(defaultAction);
       
                
        self.present(alertController, animated: true, completion: nil);
    }
    
    func createActionSheet(title: String! = "", message: String! = StringLiterals.chooseOne, ltrActions: [UIAlertAction]! = [] ,
                           preferredActionPosition: Int = 0, sender: UIView? = nil ){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet);
        
        if(ltrActions.count == 0){
            let defaultAction = UIAlertAction(title: StringLiterals.ok, style: .default, handler: nil);
            alertController.addAction(defaultAction);
        } else {
            for (index , x) in ltrActions.enumerated() {
                alertController.addAction(x as UIAlertAction);
                if index == preferredActionPosition {
                    alertController.preferredAction = x as UIAlertAction
                }
            }
        }
        
        if let popoverController = alertController.popoverPresentationController, let sender = sender {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        self.present(alertController, animated: true, completion: nil);
    }
    
    func creatAlertAction(_ title: String! = "Ok", style: UIAlertAction.Style = .default, clicked: ((_ action: UIAlertAction) -> Void)?) -> UIAlertAction! {
        return UIAlertAction(title: title, style: style, handler: clicked);
    }
}

// MARK - Progress Loading Indicator

protocol ProgressLoadingIndicators {
    func showProgressIndicator(withMessage message: String)
    func dismissProgressIndicator()
    func showNetworkIndicator(status: Bool)
}

extension ProgressLoadingIndicators where Self: UIViewController {
    
    func showProgressIndicator(withMessage message: String) {
        self.view.endEditing(true)
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = message
        hud.mode = MBProgressHUDMode.indeterminate
        hud.isUserInteractionEnabled = false
        showNetworkIndicator(status: true)
    }
    
    func dismissProgressIndicator() {
        MBProgressHUD.hide(for: self.view, animated: true)
        showNetworkIndicator(status: false)
    }
    
    func showNetworkIndicator(status: Bool = true) {
        OperationQueue.main.addOperation {
            [weak self] in
            _ = self.debugDescription
            UIApplication.shared.isNetworkActivityIndicatorVisible = status;
        }
    }
}

extension BaseUIViewController: ProgressLoadingIndicators {}
extension BaseUITableViewController: ProgressLoadingIndicators {}

