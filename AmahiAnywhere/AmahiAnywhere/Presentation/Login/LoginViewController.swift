//
//  LoginViewController.swift
//  AmahiAnywhere
//
//  Created by Carlos Puchol on 1/27/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit

class LoginViewController: BaseUIViewController {

    @IBOutlet weak var usernameInputField: UITextField!
    @IBOutlet weak var passwordInputField: UITextField!
    
    private var presenter: LoginPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = LoginPresenter(self)
        
        usernameInputField.delegate = self
        passwordInputField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func userclickSignIn(_ sender: Any) {
        
        presenter.login(username: usernameInputField.text!,
                        password: passwordInputField.text!)
        
    }
    
}

// Mark - Login view implementations
extension LoginViewController: LoginView {
    
    
    func showHome() {
        
        let dashBoardVc = self.instantiateViewController(withIdentifier: "DashboardViewController", from: StoryBoardIdentifiers.MAIN)
        self.present(dashBoardVc, animated: true, completion: nil)
    }
    
}
