//
//  Employee.swift
//  RONetworking
//
//  Created by Robin Oster on 16/07/15.
//  Copyright (c) 2015 Rascor International AG. All rights reserved.
//

import Foundation

class Employee : ROJSONObject {
    
    required init() {
        super.init();
    }
    
    public required init(jsonData: Any) {
        super.init(jsonData: jsonData)
    }

    required init(jsonString: String) {
        super.init(jsonString:jsonString)
    }
    
    var firstname:String {
        return Value<String>.get(self, key: "firstName")
    }
    
    var lastname:String {
        return Value<String>.get(self, key: "lastName")
    }
    
    var age:Int {
        return Value<Int>.get(self, key: "age")
    }
}
