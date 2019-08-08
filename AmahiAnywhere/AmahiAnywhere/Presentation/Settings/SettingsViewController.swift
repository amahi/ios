import UIKit
import MessageUI

class SettingsViewController: BaseUITableViewController {
    
    internal var settingItems = StringLiterals.settingsSectionsSubItems
    internal var titleForSections = StringLiterals.settingsSectionsTitle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.sectionFooterHeight = 0
        
        print(getFreeSize())
    }
    
    func getFreeSize() -> Int64? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dictionary = try? FileManager.default.attributesOfFileSystem(forPath: paths.last!) {
            if let freeSize = dictionary[FileAttributeKey.systemFreeSize] as? NSNumber {
                return freeSize.int64Value
            }
        }else{
            print("Error Obtaining System Memory Info:")
        }
        return nil
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
    
    internal func signOut() {
        self.dismiss(animated: false, completion: nil)
        LocalStorage.shared.logout{}
        let loginVc = self.viewController(viewControllerClass: LoginViewController.self, from: StoryBoardIdentifiers.main)
        self.present(loginVc, animated: true, completion: nil)
    }
    
    internal func handleSignOut() {
        let refreshAlert = UIAlertController(title: StringLiterals.signOut,
                                             message:StringLiterals.signOutMessage,
                                             preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: StringLiterals.cancel, style: .default, handler: { (action: UIAlertAction!) in
            refreshAlert .dismiss(animated: true, completion: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: StringLiterals.confirm,
                                             style: .destructive, handler: { (action: UIAlertAction!) in
                                                self.signOut()
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    internal func performCacheInvalidation() {
        // Clear temp storage
        
        let clearCacheAlert = UIAlertController(title: StringLiterals.clearCacheTitle,
                                                message:StringLiterals.clearCacheMessage,
                                                preferredStyle: UIAlertController.Style.alert)

        clearCacheAlert.addAction(UIAlertAction(title: StringLiterals.cancel, style: .default, handler: { (action: UIAlertAction!) in
            clearCacheAlert .dismiss(animated: true, completion: nil)
        }))
        
        clearCacheAlert.addAction(UIAlertAction(title: StringLiterals.confirm,
                                                style: .destructive, handler: { (action: UIAlertAction!) in
                                                    FileManager.default.deleteFolder(in: FileManager.default.temporaryDirectory,
                                                                                     folderName: "cache")
                                                    self.tableView.reloadData()
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
        }
    }
    
    internal func handleShareByEmail() {
        let mailVc = configureMailComposeViewController(recipient: "",
                                                        subject: StringLiterals.shareEmailSubject,
                                                        message: StringLiterals.shareEmailMessage)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailVc, animated: true, completion: nil)
        }
    }
}

// Mark: Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
