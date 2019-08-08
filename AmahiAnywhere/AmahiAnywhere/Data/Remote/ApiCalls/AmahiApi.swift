//
//  AuthService.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/18/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation
import Alamofire


class AmahiApi {
    
    private init(){}
    
    static let shared = AmahiApi()
    
    func login(username: String! , password: String!, completion: @escaping (_ oauthResponse: OAuthResponse?) -> Void ) {
        
        let headers = [ "Content-Type": "application/x-www-form-urlencoded" ]
        
        Network.shared.request(ApiEndPoints.authenticate(), method: .post, parameters: ApiConfig.oauthCredentials(username: username, password: password),
                        headers: headers, completion: completion)
    }
    
    func getServers(completion: @escaping (_ servers: [Server]?) -> Void ) {
        Network.shared.request(ApiEndPoints.fetchServers(), completion: completion)
    }
}
