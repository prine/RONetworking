//
//  ViewController.swift
//  RONetworking
//
//  Created by Robin Oster on 16/07/15.
//  Copyright (c) 2015 Rascor International AG. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let baseWebservice:BaseWebservice = BaseWebservice();
        
        let urlToJSON = "http://prine.ch/employeesWithout.json"
        
        let callbackReports = {(status:Int, employeeContainer:EmployeeContainer) -> () in
            
            if (status == 200) {
                print(employeeContainer.employees[0].firstname)
                print(employeeContainer.employees[0].lastname)
                
                print("Firstname: " + employeeContainer.employees[0].firstname)
                print("Lastname: " + employeeContainer.employees[0].firstname)
                print("Age: \(employeeContainer.employees[0].age)")
                
            } else {
                print("Retrieving data from Service failed with status code \(status)")
            }
        }
        
        baseWebservice.getROJSONObject(urlToJSON, callback: callbackReports, roError:{ (errorObject) -> () in
            print(errorObject.log())
        })
        
        baseWebservice.getArray(urlToJSON, callback: { (status, employees:Array<Employee>) in
            for employee in employees {
                print("Firstname with Array: \(employee.firstname)")
            }
        })
        
        baseWebservice.getString(urlToJSON, callback: { (status, jsonString) in
          print("JSON String: \(jsonString)")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

