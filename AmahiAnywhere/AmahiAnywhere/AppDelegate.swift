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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let stack = CoreDataStack(modelName: "OfflineFilesModel")!
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    
    var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        
        //LocalStorage.shared.delete(key: "walkthrough")
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: StoryBoardIdentifiers.main, bundle: nil)
        var initialViewController: UIViewController? = nil
        
        if LocalStorage.shared.contains(key: PersistenceIdentifiers.accessToken) {
            // User logged in previously
            initialViewController = mainStoryboard.instantiateViewController(withIdentifier: StoryBoardIdentifiers.tabBarController)
        } else {
            if LocalStorage.shared.contains(key: "walkthrough"){
                // User already completed the onboarding
                initialViewController = mainStoryboard.instantiateInitialViewController()
            }else{
                // User didn't complete the onboarding yet
                initialViewController = mainStoryboard.instantiateViewController(withIdentifier: StoryBoardIdentifiers.walktrhoughViewController)
            }
        }
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
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
        FileManager.default.deleteFolder(in: documentsPath, folderName: "downloads")
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
