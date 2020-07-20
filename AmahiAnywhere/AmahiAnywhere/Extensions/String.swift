//
//  String.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/19/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}

extension Notification.Name {
    static let HDATokenExpired = Notification.Name("HDATokenExpired")
    static let HDAUnreachable = Notification.Name("HDAUnreachable")
}
