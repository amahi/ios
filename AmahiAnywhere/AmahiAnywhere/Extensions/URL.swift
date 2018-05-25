//
//  URL.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 5/22/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

extension URL {
    
    var creationDate: Date? {
        return (try? resourceValues(forKeys: [.creationDateKey]))?.creationDate
    }
    
    var lastAccessDate: Date? {
        return (try? resourceValues(forKeys: [.contentAccessDateKey]))?.contentAccessDate
    }
    
    var isDirectory: Bool? {
        return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory
    }
}
