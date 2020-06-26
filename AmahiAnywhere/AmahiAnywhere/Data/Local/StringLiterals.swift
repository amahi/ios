//
//  StringLiterals.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/18/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

struct StringLiterals {
    
    // Loading Indicator Messages
    static let authenticatingUser =             "Authenticating, please wait . . ."
    static let pleaseWait =                     "Please Wait . . ."
    
    // In app strings
    static let genericNetworkError =            "An unexpected network error occurred."
    static let inCorrectLoginMessage =          "Incorrect Username or Password"
    static let fieldIsRequired =                "This Field is required!"
    static let errorDownloadingFileMessage =    "Error while downloading file"
    static let downloadingFile =                "Downloading %@"
    static let ok =                             "OK"
    static let selectYourHDA =                  "Select your HDA"
    static let offline =                        "Offline"
    static let downloads =                      "Downloads"
    static let share =                          "Share"
    static let download =                       "Download"
    static let delete =                         "Delete"
    static let availableOffline =               "Available Offline"
    static let removeOfflineMessage =           "Remove Download"
    static let stopDownload =                   "Cancel Download"
    static let chooseOne =                      "Choose One"
    static let open =                           "Open"
    static let currentSize =                    "Current size: %@"
    static let autoConnectLAN =                 "Autodetect (currently LAN)"
    static let autoConnectRemote =              "Autodetect (currently Remote)"

    // In Setting Area
    static let feedbackEmailAddress =           "support@amahi.org"
    static let feedbackEmailSubject =           "iOS Amahi Anywhere"
    static let feedbackEmailHint =              "<b>Please write the feedback</b>"
    static let shareEmailSubject =              "Check out my Amahi home server!"
    static let shareEmailMessage =              "I use the Amahi Home Server for storing, backing up and streaming all my files.\n\nCheck it out!\n\n<a href='https://www.amahi.org/'>https://www.amahi.org"
    static let emailErrorTitle =                "Couldn't Send Mail"
    static let emailErrorMessage =              "Your Device Couldn't Send Mail"
    static let disabled =                       "Disabled"
    static let accountSectionSubItems =         ["Sign Out"]
    static let settingsSectionSubItems =        ["Connection", clearCacheTitle]
    static let aboutSectionSubItems =           ["Version", "Tell a friend"]
    static let settingsSectionsTitle =          ["Account", "Settings", "About"]
    static let settingsSectionsSubItems =       [accountSectionSubItems, settingsSectionSubItems, aboutSectionSubItems]
    static let sortByName =                     "Sort by Name"
    static let sortByDate =                     "Sort by Date"
    static let sortBySize =                     "Sort by Size"
    static let sortByType =                     "Sort by Type"
    
    // In Mail Compose Controller
    
    static let cancelled =                      "Cancelled"
    static let mailCancelled =                  "Mail Cancelled"
    static let saved =                          "Saved"
    static let mailSaved =                      "Mail Saved"
    static let sent =                           "Sent"
    static let mailSent =                       "Mail Sent"
    
    static let versionNumberDictionaryKey =     "CFBundleShortVersionString"
    
    // App_id
    
    static let appID =                         "761559919"
    static let amahiUrlOnAppStore =             "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appID)"
    
    // Alert Texts
    
    static let signOut =                        "Sign Out"
    static let signOutMessage =                 "Are You Sure You Want to Sign Out ? "
    static let clearCacheTitle =                "Clear Temporary Downloads"
    static let clearCacheMessage =              "Are you sure you want to delete all temporary files ?"
    static let confirm =                        "Confirm"
    static let cancel =                         "Cancel"
}
