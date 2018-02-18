//
//  CustomerResponses.swift
//  FBNInsurance
//
//  Created by codedentwickler on 2/9/18.
//  Copyright © 2018 Cotta & Cush. All rights reserved.
//

import Foundation
import EVReflection

typealias RegisterCustomerResponse = LoginResponse

@objc(CustomerResponse)
public class CustomerResponse : EVNetworkingObject {
    
    public var status: String! = ""
    public var data: CustomerResponseData! = CustomerResponseData()
    public var message: String! = ""
    public var code: String! = ""
}


@objc(CustomerResponseData)
public class CustomerResponseData : EVNetworkingObject {
    
    public var identifier: String! = ""
    public var firstname: String! = ""
    public var lastname: String! = ""
    public var middlename: String! = ""
    public var email: String! = ""
    public var profile_id: NSNumber! = -1
    public var user_auth_id: NSNumber! = -1
    public var user_auth_status: String! = ""
    public var profile_status: String! = ""
    public var user_type: String! = ""
    public var gender: String! = ""
    public var quotes: [Quote]! = [Quote]()
}


@objc(Quote)
public class Quote : EVNetworkingObject {
    
    public var id: String! = ""
    public var quote_request_id: String! = ""
    public var premium: String! = ""
    public var contribution: String! = ""
    public var risk: String! = ""
    public var sum_assured: String! = ""
    public var is_outdated: Bool! = false
    public var assured_date_of_birth: String! = ""
    public var created_at: String! = ""
    public var frequency_of_payment: String! = ""
    public var status: String! = ""
    public var calculation: String! = ""
    public var policy_duration: String! = ""
    public var sum_assured_age: NSNumber! = -1
    public var customer_id: String! = ""
    public var customer_name: String! = ""
    public var agent_name: String! = ""
    public var product: QuoteProduct! = QuoteProduct()
    public var expected_total_contribution: String! = ""
    public var yearly_contribution: String! = ""
    public var death_benefit: String! = ""
    public var accidental_death_benefit: String! = ""
    public var risk_premium: String! = ""
    public var has_funeral_benefits: Bool! = false
    
    
    override public func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
        
        if key == "is_outdated" {
            is_outdated = value as! Bool!
        } else if key == "has_funeral_benefits" {
            has_funeral_benefits = value as! Bool!
        }
    }
}

@objc(QuoteProduct)
public class QuoteProduct : EVNetworkingObject {
    
    public var id: NSNumber! = -1
    public var name: String! = ""
    public var product_group_id: NSNumber! = -1
}
