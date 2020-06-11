//
//  HDAPinAuthVC.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 07. 31..
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit

class HDAPinAuthVC: BaseUIViewController {

    @IBOutlet var HDALabel: UILabel!
    @IBOutlet var pinTextField: UITextField!
    
    var server: Server?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        HDALabel.text = server?.name
        pinTextField.delegate = self
        
        ServerApi.shared!.loadServerRoute { (isLoadSuccessful) in
            if !isLoadSuccessful{
                let alertVC = UIAlertController(title: "Server Error", message: "There is an error with loading the server address!", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submitTapped(textField)
        return true
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        if pinTextField.text!.count >= 3 && pinTextField.text!.count <= 5{
            checkPin(pin: pinTextField.text!)
        }else{
            let alertVC = UIAlertController(title: "Error", message: "Please make sure you enter a PIN with a length of minimum 3 and maximum 5 characters!", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    func checkPin(pin: String){
        ServerApi.shared!.authenticateServerWithPIN(pin: pin) { (authResponse) in
            if let authToken = authResponse?.auth_token{
                self.saveToken(token: authToken)
                self.showShares()
            }else{
                self.showError(title: "Access Denied", message: "Your PIN access may be incorrect. It can be changed on the HDA's dashboard")
            }
        }
    }
    
    func saveToken(token: String){
        ServerApi.shared!.setAuthToken(token: token)
        LocalStorage.shared.persistString(string: token, key: server?.name ?? "")
    }
    
    func showShares(){
        let sharesVc = viewController(viewControllerClass: SharesViewController.self, from: StoryBoardIdentifiers.main)
        sharesVc.server = server
        let backItem = UIBarButtonItem()
        backItem.title = "HDAs"
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(sharesVc, animated: true)
    }
}
