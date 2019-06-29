//
//  FileSort.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/17/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

enum FileSort: String {
    case date = "Date"
    case name = "Name"
    case size = "Size"
    case type = "Type"
}

struct SortingMethod {
    static var fileSort = FileSort.name
}
