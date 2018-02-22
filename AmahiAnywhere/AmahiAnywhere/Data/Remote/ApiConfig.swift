//
//  ApiConfig.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/18/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

struct ApiConfig {
    
    static let BASE_URL =                       "INSERT BASE URL"
    
    private static let CLIENT_ID =              "INSERT CLIENT ID"
    private static let CLIENT_SECRET =          "INSERT CLIENT SECRET"
    
    
    static func oauthCredentials(username: String, password: String) -> [String : String] {
        
    let parameters =                          ["client_id": CLIENT_ID,
                                               "client_secret": CLIENT_SECRET,
                                               "username" : username,
                                               "password" : password ]
        
        return parameters
    }
}
