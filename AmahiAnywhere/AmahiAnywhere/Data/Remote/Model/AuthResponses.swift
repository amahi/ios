//
//  AuthResponses.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/18/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import EVReflection
import Foundation


@objc(OAuthResponse)
public class OAuthResponse: EVNetworkingObject {
    
    public var access_token: String? =          nil
    public var created_at: String? =            nil
}
