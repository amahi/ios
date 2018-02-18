//
//  BaseContract.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/17/18.
//  Copyright © 2018 Amahi. All rights reserved.


import Foundation

protocol BaseView: NSObjectProtocol {
    
    func showLoading()
    
    func showLoading(withMessage text: String)
    
    func dismissLoading()
    
    func showError(message text: String)
    
    func showError(title: String, message text: String)
    
    func isNetworkConnected()
}

protocol BasePresenter {
    
    func detachView()
}
