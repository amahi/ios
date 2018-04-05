//
//  BaseUIViewController.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/17/18.
//  Copyright © 2018 Amahi. All rights reserved.


import UIKit
import Foundation

class BaseUIViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove Back Button Text
        navigationItem.title = ""
    }
}

extension BaseUIViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }

}
