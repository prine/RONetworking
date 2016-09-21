//
//  EmployeeContainer.swift
//  RONetworking
//
//  Created by Robin Oster on 16/07/15.
//  Copyright (c) 2015 Rascor International AG. All rights reserved.
//

import Foundation

class EmployeeContainer : ROJSONObject {
    required init() {
        super.init();
    }
    
    public required init(jsonData: Any) {
        super.init(jsonData: jsonData)
    }
    
    required init(jsonString: String) {
        super.init(jsonString:jsonString)
    }
    
    lazy var employees:[Employee] = {
        return Value<[Employee]>.getArray(self) as [Employee]
    }()
}
