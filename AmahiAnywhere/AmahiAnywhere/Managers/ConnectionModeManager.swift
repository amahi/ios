//
//  ConnectionModeManager.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 5/27/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Alamofire
import Reachability

class ConnectionModeManager {
    
    private let MinimumConnectionCheckPeriod = 3.0
    
    var lastCheckedAt: Date?
    var lastCheckPassed = true
    var currentMode: ConnectionMode?
    var currentConnectionInfo: ServerRoute?
    
    var reachability: Reachability?
    
    private init(){
        
        lastCheckedAt = nil
        currentMode = LocalStorage.shared.userConnectionPreference
    }
    
    static let shared = ConnectionModeManager()
    
    func setupReachability(_ hostName: String?) {
        if let hostName = hostName {
         try!   reachability = Reachability(hostname: hostName)
        } else {
          try!  reachability = Reachability()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
    }
    
    private func reset() {
        lastCheckPassed = false
        lastCheckedAt = nil
    }
    
    private func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            AmahiLogger.log("Unable to start notifier")
            return
        }
    }
    
    private func stopNotifier() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        reachability = nil
    }
    
    func testLocalAvailability() {
        
        AmahiLogger.log("testLocalAvailability was called")
        
        if lastCheckedAt != nil && fabs(Float(lastCheckedAt!.timeIntervalSinceNow)) <= Float(MinimumConnectionCheckPeriod)  {
                 AmahiLogger.log("local checking ratelimit exceeded. last cheked %.1fs ago", fabs(Float((lastCheckedAt?.timeIntervalSinceNow)!)))
            return
        }
        
        if currentMode != ConnectionMode.auto {
            return
        }
        
        let url = localAvailabilityURL()
        
        AmahiLogger.log("trying local reachability test with url: \(url!)")
        
        guard url != nil else {
            AmahiLogger.log("local availability URL is nil")
            return
        }
        
        // Make Request
        AmahiLogger.log("Making server availability request  \(url!)")

        Alamofire.SessionManager.default.requestWithoutCache(url!,
                                                             headers: ServerApi.shared!.getServerHeaders(),
                                                             timeoutInterval: 3.0)?
            .responseJSON(completionHandler: { (response) in

                switch response.result {
                    case .success:
                        if let data = response.result.value {
                            self.lastCheckPassed = data is [Any]
                        } else{
                            self.lastCheckPassed = false
                        }
                    
                    case .failure(let error):
                        if response.response?.statusCode == 401{
                            self.lastCheckPassed = true
                        }else{
                            self.lastCheckPassed = false
                            AmahiLogger.log("local availability check return with error \(error)")
                        }
                }
                
                self.lastCheckedAt = Date()
                AmahiLogger.log("Last check passed after testLocalAvailability completed \(self.lastCheckPassed)")
                
                if self.lastCheckPassed {
                    NotificationCenter.default.post(name: .LanTestPassed, object: nil, userInfo: [:])
                } else {
                    NotificationCenter.default.post(name: .LanTestFailed, object: nil, userInfo: [:])
                }
            })
    }
    
    func updateCurrentConnectionInfo(connectionInfo: ServerRoute) {
        AmahiLogger.log("updateCurrentConnectionInfo was called")
        currentConnectionInfo = connectionInfo
        
        if currentMode == ConnectionMode.remote {
            lastCheckPassed = false
            return
        } else {
            lastCheckPassed = true
        }
        stopNotifier()
        setupReachability(currentConnectionInfo?.local_addr)
        startNotifier()
    }
    
    @objc private func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        reset()

        if reachability.connection != .none {
            testLocalAvailability()
        }
    }
    
    private func localAvailabilityURL() -> URL? {
        let baseURL = URL(string: currentConnectionInfo!.local_addr!)
        let finalURL = baseURL?.appendingPathComponent("/shares")
     
        return finalURL
    }
    
    private func isLocalModeAvailable() -> Bool {
        return lastCheckPassed
    }
    
    func currentConnectionBaseURL(serverRoute: ServerRoute) -> String? {
        
        if isLocalInUse() {
            AmahiLogger.log("Current mode in use \(currentMode!)")
            AmahiLogger.log("LAN mode in use")
            return serverRoute.local_addr
        }
        AmahiLogger.log("Remote mode in use")
        return serverRoute.relay_addr
    }
    
    public func isLocalInUse() -> Bool {
        if currentMode == ConnectionMode.auto {
            if isLocalModeAvailable() {
                return true
            } else {
                return false
            }
        }
        if currentMode == ConnectionMode.local {
            return true
        }
        return false
    }
    
    deinit {
        stopNotifier()
    }
}
