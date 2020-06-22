# Amahi iOS App
Amahi iOS App, new from scratch, in Swift.

[![Build Status](https://travis-ci.org/amahi/ios.svg?branch=master)](https://travis-ci.org/amahi/ios) `master`

[![Build Status](https://travis-ci.org/amahi/ios.svg?branch=beta)](https://travis-ci.org/amahi/ios) `beta`

## Requirements

- iOS 9.0+
- Xcode 9.0+

## Setup
- Do a clean `command + shift + k` or `command + option + shift + K`
- Close Xcode
- Open a terminal window, and `$ cd` into your project directory.
- Navigate to project directory where the Podfile exist.
- Run `$ pod install`
- You may require to run `$ pod update`
- `$ open AmahiAnywhere.xcworkspace` and build.
- The build may fail with a missing ApiConfig.swift file
- This file has developer/production credentials/endpoints and should not be shared. Email support at amahi dot org for a copy of this file. 

### Code Practices
Please help us follow the best practice to make it easy for the reviewer as well as the contributor.
* Please follow the guides and code standards: [Swift Style Guide](https://github.com/linkedin/swift-style-guide)
* Please follow the good iOS development practices: [iOS Good Practices](https://github.com/futurice/ios-good-practices)

### Contributing and developing a feature
* Create a new branch with a meaningful name `git checkout -b branch_name`.<br />
* Develop your feature on Xcode IDE  and run it using the simulator or connecting your own iphone.<br />
* Add the files you changed `git add file_name`.<br />
* Commit your changes `git commit -m "Message briefly explaining the feature"`.<br />
* Keep one commit per feature. If you forgot to add changes, you can edit the previous commit `git commit --amend`.<br />
* Push to your repo `git push origin branch-name`.<br />
* Go into [the Github repo](https://github.com/amahi/ios/) and create a pull request explaining your changes.<br />
* If you are requested to make changes, edit your commit using `git commit --amend`, push again and the pull request will edit automatically.<br />
* If the PR is related to any front end change, please attach relevant screenshots in the pull request description.
* When creating PRs or commiting changes. Please ensure the sensitive contents of the ApiConfig.swift file are ignored. Such PRs will be declined.

### Pods
- [Alamofire](https://github.com/Alamofire/Alamofire): Elegant HTTP Networking in Swift

- [EVReflection](https://github.com/evermeer/EVReflection): Reflection based (Dictionary, CKRecord, NSManagedObject, Realm, JSON and XML) object mapping with extensions for Alamofire

- [IQKeyboardManagerSwift](https://github.com/hackiftekhar/IQKeyboardManager): Codeless drop-in universal library allows to prevent issues of keyboard sliding up and cover UITextField/UITextView with one line of code

- [MBProgressHUD](https://github.com/jdg/MBProgressHUD): It is an iOS drop-in class that displays a translucent HUD with an indicator and/or labels while work is being done in a background thread.

- [MobileVLCKit](https://code.videolan.org/videolan/VLCKit.git): It is an Objective-C wrapper for libvlc's external interface on iOS.

- [SkyFloatingLabelTextField](https://github.com/Skyscanner/SkyFloatingLabelTextField): A beautiful and flexible text field control implementation of "Float Label Pattern". Written in Swift.

- [LightBox](https://github.com/hyperoslo/Lightbox): Provides a convenient and easy to use image viewer for iOS app, packed with with features like swipe left/right to change, double tap to zoom, pinch to zoom, caching etc.

## Support

If you have questions about Amahi or just want to interact, you can contact us via [IRC channel](http://talk.amahi.org). Don't forget that we are open to suggestions, extensions or adaptations. Feel free to discuss or propose new ideas for projects!


This app will go into the [iOS app store](https://itunes.apple.com/us/app/amahi/id761559919) and replace the current version there written in Objective C.
