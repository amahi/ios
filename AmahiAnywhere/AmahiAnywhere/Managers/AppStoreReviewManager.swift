//
//  AppStoreReviewManager.swift
//  AmahiAnywhere
//
//  Created by Anubhav Singh on 21/06/20.
//  Copyright © 2020 Amahi. All rights reserved.
//

import Foundation

import StoreKit

enum AppStoreReviewManager {

  static let minimumReviewWorthyActionCount = 19

  static func requestReviewIfAppropriate() {
    let defaults = UserDefaults.standard
    let bundle = Bundle.main

    var actionCount = defaults.integer(forKey: .reviewWorthyActionCount)


    actionCount += 1

    defaults.set(actionCount, forKey: .reviewWorthyActionCount)

    guard actionCount >= minimumReviewWorthyActionCount else {
      return
    }

    let bundleVersionKey = kCFBundleVersionKey as String
    let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
    let lastVersion = defaults.string(forKey: .lastReviewRequestAppVersion)

    // Check if this is the first request for this version of the app before continuing.
    guard lastVersion == nil || lastVersion != currentVersion else {
      return
    }

    SKStoreReviewController.requestReview()

    // Reset the action count and store the current version in User Defaults so that you don’t request again on this version of the app.
    defaults.set(0, forKey: .reviewWorthyActionCount)
    defaults.set(currentVersion, forKey: .lastReviewRequestAppVersion)
  }


}
