//
//  LoginViewController.swift
//  AmahiAnywhere
//
//  Created by Carlos Puchol on 1/27/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class LoginViewController: BaseUIViewController {

    @IBOutlet weak var usernameInputField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordInputField: SkyFloatingLabelTextField!
    
    private var presenter: LoginPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = LoginPresenter(self)
        
        usernameInputField.delegate = self
        passwordInputField.delegate = self
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameInputField {
            textField.resignFirstResponder()
            passwordInputField.becomeFirstResponder()
        }
        else if textField == passwordInputField {
            textField.resignFirstResponder()
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        (textField as! SkyFloatingLabelTextField).errorMessage = nil
        return true
    }
    
    @IBAction func userClickForgotPassword(_ sender: UIButton) {
        UIApplication.shared.open(NSURL(string:"https://www.amahi.org/forgot")! as URL)
    }
    
    @IBAction func userclickSignIn(_ sender: Any) {
        
        if (usernameInputField.text?.isEmpty)! {
            usernameInputField.errorColor = UIColor.red
            usernameInputField.errorMessage = StringLiterals.FIELD_IS_REQUIRED
            return
        }
        
        if (passwordInputField.text?.isEmpty)! {
            passwordInputField.errorColor = UIColor.red
            passwordInputField.errorMessage = StringLiterals.FIELD_IS_REQUIRED
            return
        }
        
        presenter.login(username: usernameInputField.text!,
                        password: passwordInputField.text!)
        
    }
    
}

// Mark - Login view implementations
extension LoginViewController: LoginView {
    
    func showHome() {
        
        let serverVc = self.instantiateViewController(withIdentifier: "NavigationViewController", from: StoryBoardIdentifiers.MAIN)
        self.present(serverVc, animated: true, completion: nil)
    }
    
}
