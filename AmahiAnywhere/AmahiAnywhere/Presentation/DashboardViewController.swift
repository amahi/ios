//
//  DashboardViewController.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/18/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit

class DashboardViewController: BaseUIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check access token in the debug area
        print("ACCESS TOKEN: \(LocalStorage.shared.getAccessToken()!)")
    }
    
    @IBAction func userClickSignOut(_ sender: Any) {
        
        LocalStorage.shared.logout {}
        let loginVc = self.instantiateViewController(withIdentifier: "LoginViewController" ,
                                                         from: StoryBoardIdentifiers.MAIN)
        self.present(loginVc, animated: true, completion: nil)
    }
}
