//
//  AuthTokenResponse.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 08. 01..
//  Copyright © 2019. Amahi. All rights reserved.
//

import EVReflection
import Foundation

@objc(AuthTokenResponse)
public class AuthTokenResponse: EVNetworkingObject {
    
    public var auth_token: String? =          nil
    
    // Overriding setValue for ignores undefined keys
    override public func setValue(_ value: Any!, forUndefinedKey key: String) {}
}
