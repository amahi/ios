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

struct GlobalFileSort {
    static var fileSort = FileSort.name {
        didSet{
            UserDefaults.standard.set(GlobalFileSort.fileSort.rawValue, forKey: "GlobalFileSort")
        }
    }
    
    static func setDefaultFileSort(){
        let fileSortString = UserDefaults.standard.string(forKey: "GlobalFileSort") ?? "Name"
        GlobalFileSort.fileSort = FileSort(rawValue: fileSortString) ?? .name
    }
}
