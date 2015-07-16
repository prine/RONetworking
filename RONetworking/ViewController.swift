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
        
        var baseWebservice:BaseWebservice = BaseWebservice();
        
        var urlToJSON = "http://prine.ch/employeesWithout.json"
        
        var callbackReports = {(status:Int, employeeContainer:EmployeeContainer) -> () in
            
            if (status == 200) {
                println(employeeContainer.employees[0].firstname)
                println(employeeContainer.employees[0].lastname)
                
                println("Firstname: " + employeeContainer.employees[0].firstname)
                println("Lastname: " + employeeContainer.employees[0].firstname)
                println("Age: \(employeeContainer.employees[0].age)")

            } else {
                println("Retrieving data from Service failed with status code \(status)")
            }
        }
        
        baseWebservice.getROJSONObject(urlToJSON, callback: callbackReports, roError:{ (errorObject) -> () in
            println(errorObject.log())
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

