//
//  AppDelegate.swift
//  AmahiAnywhere
//
//  Created by Carlos Puchol on 1/27/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import EVReflection
import AVFoundation
import GoogleCast

let kPrefPreloadTime = "preload_time_sec"
let kPrefEnableAnalyticsLogging = "enable_analytics_logging"
let kPrefAppVersion = "app_version"
let kPrefSDKVersion = "sdk_version"
let kPrefEnableMediaNotifications = "enable_media_notifications"

let appDelegate = (UIApplication.shared.delegate as? AppDelegate)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    fileprivate var firstUserDefaultsSync = false
    fileprivate var enableSDKLogging = true
    fileprivate var useCastContainerViewController = false
    
    let appID = ApiConfig.appID
    let stack = CoreDataStack(modelName: "LocalFilesModel")!
    
    var window: UIWindow?
    var backgroundSessionCompletionHandler: (() -> Void)?
    var mediaNotificationsEnabled = false
    var isCastControlBarsEnabled: Bool {
        get {
            if useCastContainerViewController {
                let castContainerVC = (window?.rootViewController as? GCKUICastContainerViewController)
                return castContainerVC!.miniMediaControlsItemEnabled
            } else {
                let rootContainerVC = (window?.rootViewController as? RootContainerViewController)
                return rootContainerVC!.miniMediaControlsViewEnabled
            }
        }
        set(notificationsEnabled) {
            if useCastContainerViewController {
                var castContainerVC: GCKUICastContainerViewController?
                castContainerVC = (window?.rootViewController as? GCKUICastContainerViewController)
                castContainerVC?.miniMediaControlsItemEnabled = notificationsEnabled
            } else {
                var rootContainerVC: RootContainerViewController?
                rootContainerVC = (window?.rootViewController as? RootContainerViewController)
                rootContainerVC?.miniMediaControlsViewEnabled = notificationsEnabled
            }
        }
    }
    
    var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        populateRegistrationDomain()
        
        useCastContainerViewController = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(syncWithUserDefaults),
                                               name: UserDefaults.didChangeNotification,
                                               object: nil)
        firstUserDefaultsSync = true
        syncWithUserDefaults()
        GCKCastContext.sharedInstance().sessionManager.add(self)
        
        let options = GCKCastOptions(discoveryCriteria: GCKDiscoveryCriteria(applicationID: appID))
        options.physicalVolumeButtonsWillControlDeviceVolume = true
        GCKCastContext.setSharedInstanceWith(options)
        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
        
        let logFilter = GCKLoggerFilter()
        logFilter.minimumLevel = .verbose
        GCKLogger.sharedInstance().filter = logFilter
        GCKLogger.sharedInstance().delegate = self
        
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        
        //LocalStorage.shared.delete(key: "walkthrough")
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: StoryBoardIdentifiers.main, bundle: nil)
        var initialViewController: UIViewController? = nil
        
        if LocalStorage.shared.contains(key: PersistenceIdentifiers.accessToken) {
            
            if useCastContainerViewController {
                guard let navigationController = mainStoryboard.instantiateViewController(withIdentifier: "NavigationViewController")
                    as? UINavigationController else { return false }
                let castContainerVC = GCKCastContext.sharedInstance().createCastContainerController(for: navigationController)
                    as GCKUICastContainerViewController
                castContainerVC.miniMediaControlsItemEnabled = true
                window = UIWindow(frame: UIScreen.main.bounds)
                window?.rootViewController = castContainerVC
                window?.makeKeyAndVisible()
            } else {
                initialViewController = mainStoryboard.instantiateViewController(withIdentifier: "RootVC")
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
        } else {
            if LocalStorage.shared.contains(key: "walkthrough"){
                // User already completed the onboarding
                initialViewController = mainStoryboard.instantiateInitialViewController()
            }else{
                // User didn't complete the onboarding yet
                initialViewController = mainStoryboard.instantiateViewController(withIdentifier: StoryBoardIdentifiers.walktrhoughViewController)
            }
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        // Setting default layout view value
        GlobalLayoutView.setDefaultLayout()
        GlobalFileSort.setDefaultFileSort()
        
        // Set date formatter for EV Reflection
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        EVReflection.setDateFormatter(dateFormatter)
        
        // Setup Audio Session For Background Play
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)), mode: AVAudioSession.Mode.moviePlayback, options: AVAudioSession.CategoryOptions.allowBluetooth)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            AmahiLogger.log("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        application.beginReceivingRemoteControlEvents()
        
        // Remove previous data in core data and delete all files in download folders.
        //        removeAllDataFromDownloadsAndCoreData()
        
        // The Load some offline files. Only used for debug
        //         preloadData()
        
        // Start Autosaving, tries to do autosave every 5 minutes if any changes is waiting to be persisted.
        stack.autoSave(60 * 5)
        return true
    }
    
    func setupMiniController(){
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: StoryBoardIdentifiers.main, bundle: nil)
        var initialViewController: UIViewController? = nil
        
        if useCastContainerViewController {
            guard let navigationController = mainStoryboard.instantiateViewController(withIdentifier: "NavigationViewController")
                as? UINavigationController else { return }
            let castContainerVC = GCKCastContext.sharedInstance().createCastContainerController(for: navigationController)
                as GCKUICastContainerViewController
            castContainerVC.miniMediaControlsItemEnabled = true
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = castContainerVC
            window?.makeKeyAndVisible()
        } else {
            initialViewController = mainStoryboard.instantiateViewController(withIdentifier: "RootVC")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession
        identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        do {
            try stack.saveContext()
        } catch let error as NSError {
            AmahiLogger.log("Error while saving. \(error.localizedDescription)")
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        do {
            try stack.saveContext()
        } catch let error as NSError {
            AmahiLogger.log("Error while saving. \(error.localizedDescription)")
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.gckExpandedMediaControlsTriggered,
                                                  object: nil)
        RecentsPersistenceService.saveContext()
    }
    
    // Mark - Only for debug
    func removeAllDataFromDownloadsAndCoreData() {
        // Remove previous stuff (if any)
        do {
            try stack.dropAllData()
        } catch let error as NSError {
            AmahiLogger.log("Error droping all objects in DB  \(error.localizedDescription)")
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        FileManager.default.deleteFolder(in: documentsPath, folderName: "downloads") { (_) in }
    }
    
    // MARK: Preload Data
    func preloadData() {
        
        for i in 1..<6 {
            // Create some offline files for test
            let _ = OfflineFile(name: "Offline File: \(i)",
                mime: "text/plain",
                size: 7 * 1024 * 1024,
                mtime: Date(),
                fileUri: "",
                localPath: "",
                progress: Float(i) * 0.11,
                state: OfflineFileState.downloading,
                context: stack.context)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}

// MARK: - GCKLoggerDelegate

extension AppDelegate: GCKLoggerDelegate {
    func logMessage(_ message: String,
                    at _: GCKLoggerLevel,
                    fromFunction function: String,
                    location: String) {
        if enableSDKLogging {
            // Send SDK's log messages directly to the console.
            print("\(location): \(function) - \(message)")
        }
    }
}

// MARK: - GCKSessionManagerListener

extension AppDelegate: GCKSessionManagerListener {
    func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?) {
        if error == nil {
            if let view = window?.rootViewController?.view {
                Toast.displayMessage("Session ended", for: 3, in: view)
            }
        } else {
            let message = "Session ended unexpectedly:\n\(error?.localizedDescription ?? "")"
            showAlert(withTitle: "Session error", message: message)
        }
    }
    
    func sessionManager(_: GCKSessionManager, didFailToStart _: GCKSession, withError error: Error) {
        let message = "Failed to start session:\n\(error.localizedDescription)"
        showAlert(withTitle: "Session error", message: message)
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Working with default values

extension AppDelegate {
    func populateRegistrationDomain() {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        var appDefaults = [String: Any]()
        if let settingsBundleURL = Bundle.main.url(forResource: "Settings", withExtension: "bundle") {
            loadDefaults(&appDefaults, fromSettingsPage: "Root", inSettingsBundleAt: settingsBundleURL)
        }
        let userDefaults = UserDefaults.standard
        userDefaults.register(defaults: appDefaults)
        userDefaults.setValue(appVersion, forKey: kPrefAppVersion)
        userDefaults.setValue(kGCKFrameworkVersion, forKey: kPrefSDKVersion)
        userDefaults.synchronize()
    }
    
    func loadDefaults(_ appDefaults: inout [String: Any], fromSettingsPage plistName: String,
                      inSettingsBundleAt settingsBundleURL: URL) {
        let plistFileName = plistName.appending(".plist")
        let settingsDict = NSDictionary(contentsOf: settingsBundleURL.appendingPathComponent(plistFileName))
        if let prefSpecifierArray = settingsDict?["PreferenceSpecifiers"] as? [[AnyHashable: Any]] {
            for prefItem in prefSpecifierArray {
                let prefItemType = prefItem["Type"] as? String
                let prefItemKey = prefItem["Key"] as? String
                let prefItemDefaultValue = prefItem["DefaultValue"] as? String
                if prefItemType == "PSChildPaneSpecifier" {
                    if let prefItemFile = prefItem["File"] as? String {
                        loadDefaults(&appDefaults, fromSettingsPage: prefItemFile, inSettingsBundleAt: settingsBundleURL)
                    }
                } else if let prefItemKey = prefItemKey, let prefItemDefaultValue = prefItemDefaultValue {
                    appDefaults[prefItemKey] = prefItemDefaultValue
                }
            }
        }
    }
    
    @objc func syncWithUserDefaults() {
        let userDefaults = UserDefaults.standard
        
        let mediaNotificationsEnabled = userDefaults.bool(forKey: kPrefEnableMediaNotifications)
        GCKLogger.sharedInstance().delegate?.logMessage?("Notifications on? \(mediaNotificationsEnabled)", at: .debug, fromFunction: #function, location: "AppDelegate.swift")
        
        if firstUserDefaultsSync || (self.mediaNotificationsEnabled != mediaNotificationsEnabled) {
            self.mediaNotificationsEnabled = mediaNotificationsEnabled
            if useCastContainerViewController {
                let castContainerVC = (window?.rootViewController as? GCKUICastContainerViewController)
                castContainerVC?.miniMediaControlsItemEnabled = mediaNotificationsEnabled
            } else {
                let rootContainerVC = (window?.rootViewController as? RootContainerViewController)
                rootContainerVC?.miniMediaControlsViewEnabled = mediaNotificationsEnabled
            }
        }
        firstUserDefaultsSync = false
    }
}
