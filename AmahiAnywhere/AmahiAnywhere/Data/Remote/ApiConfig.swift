
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
    static let baseUrl =                       "https://example.com"
    static let proxyUrl =                       "https://example.com"
    static let appID =                         "AAAAAAAA"
    private static let clientId =              "C-I-D"
    private static let clientSecret =          "C-S-T"

    static func oauthCredentials(username: String, password: String) -> [String : String] {
        let parameters =                          ["client_id": clientId,
                                                   "client_secret": clientSecret,
                                                   "username" : username,
                                                   "password" : password ]
        fatalError("You may need to get dev credentials to be able to properly login into amahi.org." +
            "Get them from support at amahi dot org. Then remove this line")
        return parameters
    }
}

