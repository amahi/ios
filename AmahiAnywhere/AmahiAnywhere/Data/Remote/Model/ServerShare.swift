//
//  ServerShare.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 07/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import EVReflection
import Foundation


@objc(ServerShare)
public class ServerShare: EVNetworkingObject {
    
    public var name: String? =      nil
    public var tags: [String]? =    nil
    public var mtime: Date? =       nil
}

