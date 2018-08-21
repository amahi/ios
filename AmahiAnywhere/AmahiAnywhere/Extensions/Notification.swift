//
//  Notification.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 7/9/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let DownloadStarted = Notification.Name("DownloadStarted")
    static let DownloadCancelled = Notification.Name("DownloadCancelled")
    static let DownloadPaused = Notification.Name("DownloadPaused")
    static let DownloadCompletedSuccessfully = Notification.Name("DownloadCompletedSuccessfully")
    static let DownloadCompletedWithError = Notification.Name("DownloadCompletedWithError")
    
    static let LanTestPassed =  Notification.Name("LanTestPassed")
    static let LanTestFailed =  Notification.Name("LanTestFailed")
    
    /// Notification that is posted when the `nextTrack()` is called.
    static let NextTrackNotification = Notification.Name("NextTrackNotification")
    
    /// Notification that is posted when the `previousTrack()` is called.
    static let PreviousTrackNotification = Notification.Name("PreviousTrackNotification")
    
    /// Notification that is posted when currently playing `Asset` did change.
    static let CurrentAssetDidChangeNotification = Notification.Name("CurrentAssetDidChangeNotification")
    
    /// Notification that is posted when the internal AVPlayer rate did change.
    static let PlayerRateDidChangeNotification = Notification.Name("PlayerRateDidChangeNotification")
}
