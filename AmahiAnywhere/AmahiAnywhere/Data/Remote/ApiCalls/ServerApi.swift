//
//  ServerApi.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 07/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation
import Alamofire
import EVReflection

class ServerApi {
    public static var shared: ServerApi?
    
    private var server: Server!
    private var serverRoute: ServerRoute?
    private var serverAddress: String?
    public var auth_token: String? // if nil -> server is default welcome to amahi
    
    private init() {}
    
    public static func initialize(server: Server!) {
        destroySharedManager() // remove previous server's data
        shared = ServerApi()
        shared?.server = server
    }
    
    func setAuthToken(token: String){
        auth_token = token
    }
    
    class func destroySharedManager() {
        shared = nil
    }
    
    func getServer() -> Server? {
        return self.server
    }
    
    var isServerRouteLoaded : Bool {
        return serverRoute != nil
    }
    
    public func getServerHeaders() -> HTTPHeaders {
        if let authToken = auth_token{
            return [ "Session": server.session_token!, "Authorization": authToken]
        }else{
            return [ "Session": server.session_token! ]
        }
    }
    
    func loadServerRoute(completion: @escaping (_ isLoadSuccessful: Bool) -> Void ) {
        
        //                let fakeServerRoute = ServerRoute()
        //                fakeServerRoute.local_addr = ApiConfig.MIFI_BASE_URL
        //                self.serverRoute = fakeServerRoute
        //                completion(true)
        //                return
        //
        func updateServerRoute(serverRouteResponse: ServerRoute?) {
            guard let serverRoute = serverRouteResponse else {
                completion(false)
                return
            }
//            serverRoute.local_addr = ApiConfig.REDCHEETAH_BASE_URL
            
            self.serverRoute = serverRoute
            configureConnection()
            completion(true)
        }
        
        Network.shared.request(ApiEndPoints.getServerRoute(), headers: getServerHeaders(), completion: updateServerRoute)
    }
    
    func configureConnection() {
        
        if !isServerRouteLoaded {
            AmahiLogger.log("Route is not loaded when configureConnection was called")
            return
        }
        
        let connectionMode = LocalStorage.shared.userConnectionPreference
        ConnectionModeManager.shared.currentMode = connectionMode
        
        if connectionMode == .local {
            serverAddress = serverRoute?.local_addr
        } else if connectionMode == .remote {
            serverAddress = serverRoute?.relay_addr
        } else if connectionMode == .auto {
            startServerConnectionDetection()
        }
    }
    
    func startServerConnectionDetection() {
        ConnectionModeManager.shared.updateCurrentConnectionInfo(connectionInfo: serverRoute!)
        ConnectionModeManager.shared.testLocalAvailability()
    }
    
    var isConnected: Bool  {
        return server != nil && serverRoute != nil && serverAddress != nil
    }
    
    func getShares(completion: @escaping (_ serverShares: [ServerShare]?) -> Void ) {
        if serverRoute == nil{
            completion(nil)
        }
        
        if serverAddress == nil{
            serverAddress = ConnectionModeManager.shared.currentConnectionBaseURL(serverRoute: serverRoute!)
        }
        
        Network.shared.request(ApiEndPoints.getServerShares(serverAddress), headers: getServerHeaders(), completion: completion)
    }
    
    func authenticateServerWithPIN(pin: String, completion: @escaping (_ authResponse: AuthTokenResponse?) -> Void){
        if serverRoute == nil{
            completion(nil)
        }
        
        if serverAddress == nil{
            serverAddress = ConnectionModeManager.shared.currentConnectionBaseURL(serverRoute: serverRoute!)
        }
        
        let requestAddress = ApiEndPoints.authenticateServerWithPin(serverAddress)!
        Network.shared.authenticateHDAWithPin(requestAddress, pin: pin, completion: completion)
    }
    
    func logoutHDA(){
        if serverRoute == nil{
            return
        }
        
        if serverAddress == nil{
            serverAddress = ConnectionModeManager.shared.currentConnectionBaseURL(serverRoute: serverRoute!)
        }
        
        let requestAddress = ApiEndPoints.logoutHDA(serverAddress)!
        Network.shared.requestWithoutResponse(requestAddress, method: .post, headers: getServerHeaders())
    }
    
    public func getFiles(share: ServerShare, directory: ServerFile? = nil, completion: @escaping (_ serverFiles: [ServerFile]?) -> Void ) {
        
        func updateFiles(serverFiles: [ServerFile]?) {
            guard let files = serverFiles else {
                completion(serverFiles)
                return
            }
            for file in files {
                file.parentFile = directory
                file.parentShare = share
            }
            completion(files)
        }
        
        var params: Parameters = ["s": share.name!]
        if directory != nil {
            params["p"] = directory?.getPath()
        }
        
        print(ApiEndPoints.getServerFiles(serverAddress))
        print(getServerHeaders())
        Network.shared.request(ApiEndPoints.getServerFiles(serverAddress), parameters: params, headers: getServerHeaders(), completion: updateFiles)
    }
    
    public func deleteFiles(file: ServerFile, share: ServerShare, directory: ServerFile? = nil, completion: @escaping (_ success: Bool) -> Void ) {
        
        var params: Parameters = ["s": share.name!]
        params["p"] = "\(file.getPath())"
        print(file.getPath())
        print(params)
        
        Network.shared.delete(ApiEndPoints.getServerFiles(serverAddress), parameters: params, headers: getServerHeaders(), completion: completion)
    }
    
    public func getFileUri(_ file: ServerFile) -> URL? {
        var components = URLComponents(string: serverAddress!)!
        components.path = "/files"
        components.queryItems = [
            URLQueryItem(name: "s", value: file.parentShare!.name),
            URLQueryItem(name: "p", value: file.getPath()),
            URLQueryItem(name: "mtime", value: String(file.getLastModifiedEpoch())),
            URLQueryItem(name: "session", value: server.session_token),
        ]
        
        if let authToken = auth_token{
            components.queryItems?.append(URLQueryItem(name: "auth", value: authToken))
        }
        components.percentEncodedQuery = components.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")
        
        return components.url
    }
    
    public func getFileThumbnailUri(_ file: ServerFile) -> URL? {
        var components = URLComponents(string: serverAddress!)!
        components.path = "/cache"
        components.queryItems = [
            URLQueryItem(name: "s", value: file.parentShare!.name),
            URLQueryItem(name: "p", value: file.getPath()),
            URLQueryItem(name: "mtime", value: String(file.getLastModifiedEpoch())),
            URLQueryItem(name: "session", value: server.session_token)
        ]
        
        if let authToken = auth_token{
            components.queryItems?.append(URLQueryItem(name: "auth", value: authToken))
        }
        components.percentEncodedQuery = components.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")
        
        return components.url
    }
}
