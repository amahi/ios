//
//  ServerRoute.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 07/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import EVReflection
import Foundation


@objc(ServerRoute)
public class ServerRoute: EVNetworkingObject {
    
    public var local_addr: String? =    nil
    public var relay_addr: String? =   nil
    
    // Overriding setValue for ignores undefined keys
    override public func setValue(_ value: Any!, forUndefinedKey key: String) {}
}

extension ServerRoute {
    static func ==(lhs: ServerRoute, rhs: ServerRoute) -> Bool {
        return lhs.local_addr == rhs.local_addr && lhs.relay_addr == rhs.relay_addr
    }
}

enum ConnectionMode: String {
    case auto =             "Autodetect"
    case local =            "LAN"
    case remote =           "Remote"
    
    static let allValues = [auto, local, remote]
}
