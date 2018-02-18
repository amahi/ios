//
//  LoginPresenter.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/18/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

protocol LoginView : BaseView {
    
    func showHome()
}

class LoginPresenter: BasePresenter {
    
    weak private var view: LoginView?
    
    init(_ view: LoginView) {
        self.view = view
    }
    
    func detachView() {
        self.view = nil
    }
    
    func login(username: String! ,password: String!) {

        
        self.view?.showLoading(withMessage: StringLiterals.AUTHENTICATING_USER)
        
        AuthService.shared.oauth(username: username, password: password) { (oauthResponse) in
            self.view?.dismissLoading()
            
            guard let response = oauthResponse else {
                self.view?.showError(message: StringLiterals.GENERIC_NETWORK_ERROR)
                self.view?.showHome()
                return
            }
            
            if let access_token = response.access_token {
                // Store Access Token for Future use
                LocalStorage.shared.persistString(string: access_token, key: PersistenceIdentifiers.ACCESS_TOKEN)
                self.view?.showHome()
            } else {
                self.view?.showError(message: response.message)
            }
            
            
        }
        
    }
}
