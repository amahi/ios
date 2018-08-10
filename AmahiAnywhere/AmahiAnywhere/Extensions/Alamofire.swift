//
//  Alamofire.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 5/27/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Alamofire

extension Alamofire.SessionManager {
    @discardableResult
    open func requestWithoutCache(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        timeoutInterval: TimeInterval ) -> DataRequest? {
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: headers)
            urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData // <<== Cache disabled
            urlRequest.timeoutInterval = timeoutInterval
            let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
            return request(encodedURLRequest)
        } catch {
            // TODO: find a better way to handle error
            AmahiLogger.log(error)
            return nil
        }
    }
}
