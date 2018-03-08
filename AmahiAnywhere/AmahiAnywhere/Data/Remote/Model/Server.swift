//
//  Server.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 05/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import EVReflection
import Foundation


@objc(Server)
public class Server: EVNetworkingObject {
    
    public var name: String? =              nil
    public var session_token: String? =     nil
    public var active: Bool =               false
}
