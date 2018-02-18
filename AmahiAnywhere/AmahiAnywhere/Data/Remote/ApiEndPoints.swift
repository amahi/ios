//
//  ApiEndPoints.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/18/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

struct ApiEndPoints {
    
    // Mark - Authentication Endpoints
    
    static func authenticate() -> String! {
        return "\(ApiConfig.BASE_URL)/api2/oauth/token?grant_type=password"
    }
    
}
