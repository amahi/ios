//
//  SettingsViewController+MFMailComposeViewControllerDelegate.swift
//  AmahiAnywhere
//
//  Created by Kanyinsola Fapohunda on 03/04/2019.
//  Copyright © 2019 Amahi. All rights reserved.
//

import MessageUI

// Mark: MFMailComposeViewControllerDelegate

extension SettingsViewController : MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller:MFMailComposeViewController,
                               didFinishWith result:MFMailComposeResult, error:Error?) {
        switch result {
        case .cancelled:
            let myalert = UIAlertController(title: StringLiterals.cancelled, message: StringLiterals.mailCancelled, preferredStyle: UIAlertController.Style.alert)
            
            myalert.addAction(UIAlertAction(title: StringLiterals.ok, style: .default) { (action:UIAlertAction!) in
            })
            self.present(myalert, animated: true)
        case .saved:
            let myalert = UIAlertController(title: StringLiterals.saved, message: StringLiterals.mailSaved, preferredStyle: UIAlertController.Style.alert)
            
            myalert.addAction(UIAlertAction(title: StringLiterals.ok, style: .default) { (action:UIAlertAction!) in
            })
            self.present(myalert, animated: true)
        case .sent:
            let myalert = UIAlertController(title: StringLiterals.sent, message: StringLiterals.mailSent, preferredStyle: UIAlertController.Style.alert)
            
            myalert.addAction(UIAlertAction(title: StringLiterals.ok, style: .default) { (action:UIAlertAction!) in
            })
            self.present(myalert, animated: true)
            
        case .failed:
            AmahiLogger.log("Mail sent failure: \(String(describing: error?.localizedDescription))")
            // default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
}
