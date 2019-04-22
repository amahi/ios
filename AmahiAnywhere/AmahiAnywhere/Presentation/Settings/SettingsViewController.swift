import UIKit
import MessageUI

class SettingsViewController: BaseUITableViewController {
    
    internal var settingItems = StringLiterals.settingsSectionsSubItems
    internal var titleForSections = StringLiterals.settingsSectionsTitle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    internal func configureMailComposeViewController(recipient: String,
                                            subject: String,
                                            message: String) ->MFMailComposeViewController {
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients([recipient])
        mail.setSubject(subject)
        mail.setMessageBody(message, isHTML: true)
        
        return mail
    }
    
    internal func showSendMailErrorAlert() {
        let sendMailAlert = UIAlertController(title: StringLiterals.emailErrorTitle,
                                              message: StringLiterals.emailErrorMessage,
                                              preferredStyle: UIAlertController.Style.alert)
        
        sendMailAlert.addAction(UIAlertAction(title: StringLiterals.ok, style: .default) { (action:UIAlertAction!) in
        })
        self.present(sendMailAlert, animated: true)
    }
        
    internal func signOut() {
        self.dismiss(animated: false, completion: nil)
        LocalStorage.shared.logout {}
        let loginVc = self.viewController(viewControllerClass: LoginViewController.self, from: StoryBoardIdentifiers.main)
        self.present(loginVc, animated: true, completion: nil)
    }
    
    internal func handleSignOut() {
        let refreshAlert = UIAlertController(title: StringLiterals.signOut,
                                             message:StringLiterals.signOutMessage,
                                             preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: StringLiterals.confirm,
                                             style: .destructive, handler: { (action: UIAlertAction!) in
                                                self.signOut()
        }))
        refreshAlert.addAction(UIAlertAction(title: StringLiterals.cancel, style: .default, handler: { (action: UIAlertAction!) in
            refreshAlert .dismiss(animated: true, completion: nil)
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    internal func performCacheInvalidation() {
        // Clear temp storage
        
        let clearCacheAlert = UIAlertController(title: StringLiterals.clearCacheTitle,
                                                message:StringLiterals.clearCacheMessage,
                                                preferredStyle: UIAlertController.Style.alert)
        clearCacheAlert.addAction(UIAlertAction(title: StringLiterals.confirm,
                                                style: .destructive, handler: { (action: UIAlertAction!) in
                                                    
                                                    FileManager.default.deleteFolder(in: FileManager.default.temporaryDirectory,
                                                                                     folderName: "cache")
                                                    self.tableView.reloadData()
        }))
        clearCacheAlert.addAction(UIAlertAction(title: StringLiterals.cancel, style: .default, handler: { (action: UIAlertAction!) in
            clearCacheAlert .dismiss(animated: true, completion: nil)
        }))
        present(clearCacheAlert, animated: true, completion: nil)
    }
    
    internal func openAmahiOnAppStore() {
        let urlStr = StringLiterals.amahiUrlOnAppStore
        if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    internal func handleFeedbackByEmail() {
        let mailVc = configureMailComposeViewController(recipient: StringLiterals.feedbackEmailAddress,
                                                        subject: StringLiterals.feedbackEmailSubject,
                                                        message: StringLiterals.feedbackEmailHint)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailVc, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    internal func handleShareByEmail() {
        let mailVc = configureMailComposeViewController(recipient: "",
                                                        subject: StringLiterals.shareEmailSubject,
                                                        message: StringLiterals.shareEmailMessage)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailVc, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
}

// Mark: Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
