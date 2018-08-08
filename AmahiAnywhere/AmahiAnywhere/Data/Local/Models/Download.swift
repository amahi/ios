//
//  Download.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/17/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

class Download {
    
    var offlineFile: OfflineFile
    
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeData: Data?
    var progress: Float = 0
    
    init(offlineFile: OfflineFile) {
        self.offlineFile = offlineFile
    }
}
