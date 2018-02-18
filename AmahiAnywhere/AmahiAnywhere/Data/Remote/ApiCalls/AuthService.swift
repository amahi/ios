//
//  AuthService.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 2/18/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation
import Alamofire


class AuthService {
    
    private init(){}
    
    static let shared = AuthService()
    
    func oauth(username: String! , password: String!, completion: @escaping (_ oauthResponse: OAuthResponse?) -> Void ) {
        
        let headers = [ "Content-Type": "application/x-www-form-urlencoded" ]
        
        Alamofire.request(ApiEndPoints.authenticate(), method: .post,
                          parameters: ApiConfig.oauthCredentials(username: username, password: password), headers: headers)
            .responseObject { (response: DataResponse<OAuthResponse>) in
                
                switch response.result {
                    case .success:
                        if let data = response.result.value {
                            completion(data)
                        }else{
                            completion(nil);
                        }
                    
                    case .failure(let error):
                        debugPrint(error)
                        completion(nil);
                }
        }
    }
     
}
