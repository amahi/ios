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
    static let AUTHENTICATING_USER =            "Authenticating, please wait . . ."
    static let PLEASE_WAIT =                    "Please Wait . . ."
    
    // In app strings
    static let GENERIC_NETWORK_ERROR =          "An unexpected network error occurred."
    static let INCORRECT_PASSWORD =             "Incorrect Username or Password"
    static let FIELD_IS_REQUIRED =              "This Field is required!"
    static let ERROR_DOWNLOADING_FILE =         "Error while downloading file"
    static let DOWNLOADING_FILE =               "Downloading %@"
    
    // In Setting Area
    static let FEEDBACK_RECEPIENT =             "support@amahi.org"
    static let FEEDBACK_SUBJECT =               "iOS Amahi Anywhere"
    static let FEEDBACK_MSG =                   "<b>Please write the feedback</b>"
    static let SHARE_SUBJECT =                  "Check out my Amahi home server!"
    static let SHARE_MESSAGE =                  "I use the Amahi Home Server for storing, backing up and streaming all my files.\n\nCheck it out!\n\n<a href='https://www.amahi.org/'>https://www.amahi.org"
    static let MAIL_ERROR_TITLE =               "Couldn't Send Mail"
    static let MAIL_ERROR_MESSAGE =             "Your Device Couldn't Send Mail"
    static let ALERT_ACTION =                   "OK"
    static let DISABLED =                       "Disabled"
    static let ACCOUNT =                        ["Sign Out"]
    static let SETTINGS =                       ["Connection"]
    static let ABOUT =                          ["Version",  "Rate", "Feedback", "Tell a friend"]
    static let SETTINGS_SECTION_TITLES =        ["Account", "Settings", "About"]
    static let SETTINGS_ACTION_TITLES =         [ACCOUNT, SETTINGS, ABOUT]    
    
    // In Mail Compose Controller
    
    static let CANCEL_TITLE =                   "Cancelled"
    static let CANCEL_MESSAGE =                 "Mail Cancelled"
    static let SAVED_TITLE =                    "Saved"
    static let SAVED_MESSAGE =                  "Mail Saved"
    static let SENT_TITLE =                     "Sent"
    static let SENT_MESSAGE =                   "Mail Sent"
    
    // In Delegates Method
    
    static let ABOUT_TITLE =                    "Version"
    static let INFO_DICTIONARY_KEY =            "CFBundleShortVersionString"
    
    // App_id
    
    static let APP_ID =                         "761559919"
    static let URL =                            "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(APP_ID)"
    
    // In SignOut
    
    static let SIGNOUT_TITLE =                  "Sign Out"
    static let SIGNOUT_MESSAGE =                "Are You Sure You Want to Sign Out ? "
    static let SIGNOUT_CONFIRM_TITLE =          "Confirm"
    static let SIGNOUT_CANCLE_TITLE =           "Cancel"
}
