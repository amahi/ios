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
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.secondarySystemBackground
        } else {
            self.view.backgroundColor = UIColor(hex: "1E2023")
        }
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
                                                    FileManager.default.deleteFolder(in: FileManager.default.temporaryDirectory, folderName: "cache", completion: { (success) in
                                                        if success{
                                                            self.showStatusAlert(title: "Successfully cleared temporary downloads")
                                                        }
                                                    })
                                                    self.tableView.reloadData()
        }))
        
        present(clearCacheAlert, animated: true, completion: nil)
    }
    
    
    func handleShareByEmail() {
        let activityViewController = UIActivityViewController(activityItems: [productURL],
                                                              applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
}

private let productURL = URL(string: "https://apps.apple.com/us/app/amahi/id761559919?ls=1")!

// Mark: Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

