//
//  ********************************************************
//  *************   DO NOT COMMMIT THIS FILE   *************
//  *************         DO NOT SHARE IT      *************
//  ************* It Has Sensitive Credentials *************
//  ********************************************************
//
//  Dummy credentials file.
//
//  AmahiAnywhere/AmahiAnywhere/Data/Remote/ApiConfig.swift
//
//  AmahiAnywhere
//
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

struct ApiConfig {
    
    static let BASE_URL =                       "https://example.com"
    static let PROXY_URL =                       "https://example.com"
    
    private static let CLIENT_ID =              "C-I-D"
    private static let CLIENT_SECRET =          "C-S-T"
    
    static func oauthCredentials(username: String, password: String) -> [String : String] {
        
        let parameters =                          ["client_id": CLIENT_ID,
                                                   "client_secret": CLIENT_SECRET,
                                                   "username" : username,
                                                   "password" : password ]
        
        fatalError("You may need to get dev credentials to be able to properly login into amahi.org." +
            "Get them from support at amahi dot org. Then remove this line")
        
        return parameters
    }
}

