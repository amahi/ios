//
//  OfflineFileIndexes.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 07. 05..
//  Copyright © 2019. Amahi. All rights reserved.
//

import Foundation

struct OfflineFileIndexes{
    static var offlineFilesIndexPaths = [OfflineFile: IndexPath]()
    static var indexPathsForOfflineFiles = [IndexPath: OfflineFile]()
}

struct OfflineFileIndexesRecents{
    static var offlineFilesIndexPaths = [OfflineFile: IndexPath]()
    static var indexPathsForOfflineFiles = [IndexPath: OfflineFile]()
}
