//
//  Date.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 5/24/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

extension Date {
    
    static func daysAgo(days:Int) -> Date? {
        return Date().addingTimeInterval(TimeInterval(-days * 24 * 60 * 60))
    }
}
