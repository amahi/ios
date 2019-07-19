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
    
    private func getDefaultHeaders() -> HTTPHeaders {
        return [
            "Accept": "application/json"
            // TODO: Add User-Agent header
        ]
    }
    
    private func getFinalHeaders(_ headers: HTTPHeaders) -> HTTPHeaders {
        var finalHeaders = getDefaultHeaders()
        for (key, value) in headers {
            finalHeaders[key] = value
        }
        return finalHeaders
    }
    
    public func request<T: NSObject>(_ url: String!, method: HTTPMethod! = .get, parameters: Parameters = [:], headers: HTTPHeaders = [:],
                                            completion: @escaping (_ response: T?) -> Void) where T: EVReflectable {
        
        Alamofire.request(url, method: method, parameters: parameters, headers: getFinalHeaders(headers))
            .responseObject {(response: DataResponse<T>) in
                
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
                if response.response?.statusCode == 200 {
                    completion(true)
                }
                else {
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
            
                if response.error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
        }
    }
}
