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
    
    private init(_ server: Server) {
        self.server = server
    }

    public static func initialize(server: Server!) {
        self.shared = ServerApi(server)
    }
    
    func getServer() -> Server? {
        return self.server
    }
    
    private func getSessionHeader() -> HTTPHeaders {
        return [ "Session": server.session_token! ]
    }
    
    func loadServerRoute(completion: @escaping (_ isLoadSuccessful: Bool) -> Void ) {
        
        func updateServerRoute(serverRouteResponse: ServerRoute?) {
            guard let serverRoute = serverRouteResponse else {
                completion(false)
                return
            }
            self.serverRoute = serverRoute
            self.serverAddress = serverRoute.relay_addr
            completion(true)
        }
        
        Network.request(ApiEndPoints.getServerRoute(), headers: getSessionHeader(), completion: updateServerRoute)
    }
    
    func getShares(completion: @escaping (_ serverRoute: [ServerShare]?) -> Void ) {
        Network.request(ApiEndPoints.getServerShares(serverAddress), headers: getSessionHeader(), completion: completion)
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
        
        Network.request(ApiEndPoints.getServerFiles(serverAddress), parameters: params, headers: getSessionHeader(), completion: updateFiles)
    }
    
    public func getFileUri(_ file: ServerFile) -> URL {
        var components = URLComponents(string: serverAddress!)!
        components.path = "/files"
        components.queryItems = [
            URLQueryItem(name: "s", value: file.parentShare!.name),
            URLQueryItem(name: "p", value: file.getPath()),
            URLQueryItem(name: "mtime", value: String(file.getLastModifiedEpoch())),
            URLQueryItem(name: "session", value: server.session_token)
        ]
        return try! components.asURL()
    }
    
}





