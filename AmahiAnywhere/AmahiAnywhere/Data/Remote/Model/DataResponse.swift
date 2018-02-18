//
//  DataResponse.swift
//  FBNInsurance
//
//  Created by codedentwickler on 2/9/18.
//  Copyright © 2018 Cotta & Cush. All rights reserved.
//

import Foundation
import EVReflection

@objc(DataListResponseData)
public class DataListResponseData : EVNetworkingObject {
    
    public var id:         String! = ""
    public var name:       String! = ""
    public var key:        String! = ""
    public var is_active:  String! = ""
    public var created_at: String! = ""
    public var updated_at: String! = ""
}

@objc(DataListResponse)
public class DataListResponse : EVNetworkingObject {
    
    public var status:  String! = ""
    public var data:    [DataListResponseData]! = [DataListResponseData]()
    public var message: String! = ""
}
