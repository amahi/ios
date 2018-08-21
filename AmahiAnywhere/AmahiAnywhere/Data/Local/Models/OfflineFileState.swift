//
//  OfflineFileState.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/15/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

enum OfflineFileState: Int16 {
    case downloaded = 1 , downloading, outdated, completedWithError, none 
}
