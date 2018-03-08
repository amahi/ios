//
//  ApiEndPoints.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 07/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

struct ApiEndPoints {

    static func authenticate() -> String! {
        return "\(ApiConfig.BASE_URL)/api2/oauth/token?grant_type=password"
    }

    static func fetchServers() -> String! {
        return "\(ApiConfig.BASE_URL)/api2/servers?access_token=\(LocalStorage.shared.getAccessToken()!)"
    }

    static func getServerRoute() -> String! {
        return "\(ApiConfig.PROXY_URL)/client"
    }

    static func getServerShares(_ serverUrl: String!) -> String! {
        return "\(serverUrl!)/shares"
    }
    
    static func getServerFiles(_ serverUrl: String!) -> String! {
        return "\(serverUrl!)/files"
    }
}
