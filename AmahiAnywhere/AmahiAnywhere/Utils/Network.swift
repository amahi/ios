//
//  Network.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 07/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation
import Alamofire
import EVReflection

public class Network {
    
    private init(){}
    
    static let shared = Network()
    
    //eg. iOS/10_1
       func deviceVersion() -> String {
           let currentDevice = UIDevice.current
           return "\(currentDevice.systemName)/\(currentDevice.systemVersion)"
       }
       //eg. iPhone5,2
       func deviceName() -> String {
           var sysinfo = utsname()
           uname(&sysinfo)
           return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
       }
       //eg. MyApp/1
       func appNameAndVersion() -> String {
           let dictionary = Bundle.main.infoDictionary!
           let version = dictionary["CFBundleShortVersionString"] as! String
           let name = dictionary["CFBundleName"] as! String
           return "\(name)/\(version)"
       }
       
       private func getDefaultHeaders() -> HTTPHeaders {
           return [
               "Accept": "application/json" +
               "\(appNameAndVersion()) \(deviceName()) \(deviceVersion())"
           ]
       }

    
    private func getFinalHeaders(_ headers: HTTPHeaders) -> HTTPHeaders {
        var finalHeaders = getDefaultHeaders()
        for (key, value) in headers {
            finalHeaders[key] = value
        }
        return finalHeaders
    }
    
    public func requestWithoutResponse(_ url: String, method: HTTPMethod, parameters: Parameters = [:], encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders = [:]){
        Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: getFinalHeaders(headers)).response { (dataResponse) in
            if let response = dataResponse.response{
                print("Request sent successfully and received status code is \(response.statusCode)")
            }else{
                print("No response received from the server")
            }
        }
    }
    
    public func authenticateHDAWithPin(_ url: String, pin: String, completion: @escaping (_ authResponse: AuthTokenResponse?) ->()){
        let headers = getFinalHeaders(["Content-Type": "application/json"])
        Alamofire.request(url, method: .post, parameters: ["pin": pin], encoding: JSONEncoding.default, headers: headers).responseData { (response) in
            if response.response?.statusCode == 200, let data = response.result.value{
                completion(AuthTokenResponse(data: data))
            }else{
                completion(nil)
            }
        }
    }

    
    public func request<T: NSObject>(_ url: String!, method: HTTPMethod! = .get, parameters: Parameters = [:], encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders = [:],
                                            completion: @escaping (_ response: T?) -> Void) where T: EVReflectable {
        Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: getFinalHeaders(headers))
            .responseObject {(response: DataResponse<T>) in
                if response.response?.statusCode == 401{
                    NotificationCenter.default.post(name: .HDATokenExpired, object: nil)
                    completion(nil)
                }
                
//                AmahiLogger.log("Request to \(url!) returned with STATUS CODE \(response.response?.statusCode)") // <<<<<<<<<<<<<
                switch response.result {
                    case .success:
                        if let data = response.result.value {
                            completion(data)
                        } else {
                            completion(nil);
                        }
                    
                    case .failure(let error):
                        AmahiLogger.log(error)
                        completion(nil);
                }
        }
    }
    
    public func request<T: NSObject>(_ url: String!, method: HTTPMethod! = .get, parameters: Parameters = [:], headers: HTTPHeaders = [:],
                                            completion: @escaping (_ response: [T]?) -> Void) where T: EVReflectable {

        Alamofire.request(url, method: method, parameters: parameters, headers: getFinalHeaders(headers))
            .responseArray {(response: DataResponse<[T]>) in
                if response.response?.statusCode == 401{
                    NotificationCenter.default.post(name: .HDATokenExpired, object: nil)
                    completion(nil)
                }
                
                switch response.result {
                case .success:
                    if let data = response.result.value {
                        completion(data)
                    } else{
                        completion(nil);
                    }
                    
                case .failure(let error):
                    AmahiLogger.log(error)
                    completion(nil);
                }
        }
    }
    
    public func delete(_ url: String!, method: HTTPMethod! = .delete, parameters: Parameters = [:], headers: HTTPHeaders = [:], completion: @escaping (_ isSuccessful: Bool ) -> Void) {
        Alamofire.request(url, method: method, parameters: parameters, headers: getFinalHeaders(headers))
            .response { response in
                if response.response?.statusCode == 401{
                    NotificationCenter.default.post(name: .HDATokenExpired, object: nil)
                    completion(false)
                }
                
                if response.response?.statusCode == 200 {
                    completion(true)
                }
                else {
                    completion(false)
                }
        }
    }
    
    func downloadRecentFileToStorage(recentFile: Recent,
                                            progressCompletion: @escaping (_ percent: Float) -> Void,
                                            completion: @escaping (_ isSuccessful: Bool ) -> Void) {
        // Create destination URL
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            
            let tempDirectoryURL = FileManager.default.findOrCreateFolder(in: FileManager.default.temporaryDirectory,
                                                                          folderName: "cache")
            
            let destinationFileUrl = tempDirectoryURL?.appendingPathComponent(recentFile.path)
            
            return (destinationFileUrl!, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        guard let fileURL = URL(string: recentFile.fileURL) else { return }
        
        Alamofire.download(fileURL, to: destination)
            .downloadProgress { progress in
                progressCompletion(Float(progress.fractionCompleted))
            }
            .response { response in
        
                if response.error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
        }
    }
    
    public func downloadFileToStorage(file: ServerFile,
                                      progressCompletion: @escaping (_ percent: Float) -> Void,
                                      completion: @escaping (_ isSuccessful: Bool ) -> Void) {

        // Create destination URL
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            
            let tempDirectoryURL = FileManager.default.findOrCreateFolder(in: FileManager.default.temporaryDirectory,
                                                                    folderName: "cache")

            let destinationFileUrl = tempDirectoryURL?.appendingPathComponent(file.getPath())
            
            return (destinationFileUrl!, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        guard let fileUrl = ServerApi.shared!.getFileUri(file) else {
            AmahiLogger.log("Invalid file URL, attempt to download file failed")
            return
        }
            
        Alamofire.download(fileUrl, to: destination)
            .downloadProgress { progress in
                progressCompletion(Float(progress.fractionCompleted))
            }
            .response { response in
                
                if response.response?.statusCode == 401{
                    NotificationCenter.default.post(name: .HDATokenExpired, object: nil)
                    completion(false)
                }
            
                if response.error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
        }
    }
}
