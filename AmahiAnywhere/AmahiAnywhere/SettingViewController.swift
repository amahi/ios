//
//  SettingViewController.swift
//  AmahiAnywhere
//
//  Created by Syed on 28/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit
import MessageUI

class SettingViewController: UITableViewController,MFMailComposeViewControllerDelegate {
    
    var settingItems = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        settingItems = ["Connection","About","Rate","Feedback","Sign Out"]
    }
    override func didReceiveMemoryWarning() {
         super.didReceiveMemoryWarning()
    }
    func configureMailComposeViewController() ->MFMailComposeViewController {
        
                let mail = MFMailComposeViewController()
               mail.mailComposeDelegate = self
                mail.setToRecipients([StringLiterals.RECEPIENT])
                mail.setSubject(StringLiterals.SUBJECT)
                mail.setMessageBody(StringLiterals.MESSAGE, isHTML: true)
        
                return mail
            }
        func showSendMailErrorAlert()
        {
            let sendMailAlert = UIAlertController(title: StringLiterals.ERROR_TITLE, message: StringLiterals.ERROR_MESSAGE, preferredStyle: UIAlertControllerStyle.alert)
    
            sendMailAlert.addAction(UIAlertAction(title: StringLiterals.ALERT_ACTION, style: .default) { (action:UIAlertAction!) in
                self.navigationController?.popToRootViewController(animated: true)
            })
            self.present(sendMailAlert, animated: true)
        }
    
        func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
                switch result {
                    case .cancelled:
                            let myalert = UIAlertController(title: StringLiterals.CANCLE_TITLE, message: StringLiterals.CANCLE_MESSAGE, preferredStyle: UIAlertControllerStyle.alert)
                
                    myalert.addAction(UIAlertAction(title: StringLiterals.ALERT_ACTION, style: .default) { (action:UIAlertAction!) in
                                self.navigationController?.popToRootViewController(animated: true)
                            })
                            self.present(myalert, animated: true)
                    case .saved:
                            let myalert = UIAlertController(title: StringLiterals.SAVED_TITLE, message: StringLiterals.SAVED_MESSAGE, preferredStyle: UIAlertControllerStyle.alert)
                
                            myalert.addAction(UIAlertAction(title: StringLiterals.ALERT_ACTION, style: .default) { (action:UIAlertAction!) in
                                self.navigationController?.popToRootViewController(animated: true)
                            })
                            self.present(myalert, animated: true)
                    case .sent:
                            let myalert = UIAlertController(title: StringLiterals.SENT_TITLE, message: StringLiterals.SENT_MESSAGE, preferredStyle: UIAlertControllerStyle.alert)
                
                            myalert.addAction(UIAlertAction(title: StringLiterals.ALERT_ACTION, style: .default) { (action:UIAlertAction!) in
                                self.navigationController?.popToRootViewController(animated: true)
                            })
                            self.present(myalert, animated: true)
                
                    case .failed:
                            print("Mail sent failure: \(String(describing: error?.localizedDescription))")
                                // default:
                            break
                    }
                self.dismiss(animated: true, completion: nil)
            }
        // MARK:- Signout function Added
    
        func signOut()
        {
            LocalStorage.shared.logout {}
            let loginVc = self.instantiateViewController(withIdentifier: StoryBoardIdentifiers.LOGINVC ,from: StoryBoardIdentifiers.MAIN)
            self.present(loginVc, animated: true, completion: nil)
        }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return settingItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingItemCell", for: indexPath)
        cell.textLabel?.text = settingItems[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        switch row
        {
        case  0 :
             performSegue(withIdentifier: SegueIdentfiers.CONNECTION, sender: nil)
        case 1:
            let versionNumber = Bundle.main.object(forInfoDictionaryKey: StringLiterals.INFO_DICTIONARY_KEY) as! String
            let myalert = UIAlertController(title: StringLiterals.ABOUT_TITLE, message: versionNumber, preferredStyle: UIAlertControllerStyle.alert)
            myalert.addAction(UIAlertAction(title: StringLiterals.ALERT_ACTION, style: .default) { (action:UIAlertAction!) in
            self.navigationController?.popToRootViewController(animated: true)
                })
            self.present(myalert, animated: true)
        case 2:
            let appID = StringLiterals.APP_ID
            let urlStr = StringLiterals.URL
            if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
            UIApplication.shared.openURL(url)
            } }
        case 3:
            let a = configureMailComposeViewController()
            if MFMailComposeViewController.canSendMail()
            {
            self.present(a, animated: true, completion: nil)
            } else {
            self.showSendMailErrorAlert() }
        case 4:
            let refreshAlert = UIAlertController(title: StringLiterals.SIGNOUT_TITLE, message:StringLiterals.SIGNOUT_MESSAGE, preferredStyle: UIAlertControllerStyle.alert)
            refreshAlert.addAction(UIAlertAction(title: StringLiterals.SIGNOUT_CONFIRM_TITLE, style: .default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popToRootViewController(animated: true)
                                        self.signOut() }))
            refreshAlert.addAction(UIAlertAction(title: StringLiterals.SIGNOUT_CANCLE_TITLE, style: .default, handler: { (action: UIAlertAction!) in
            refreshAlert .dismiss(animated: true, completion: nil)
             }))
            present(refreshAlert, animated: true, completion: nil)
        default:
            break
        }
    }
}
