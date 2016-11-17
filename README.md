# RONetworking

Is a very light-weight and straighforward JSON to object mapper. You can define your class structure and directly
define in there your accessed properties in the JSON file. The whole parsing of the JSON file is done by the library SwiftyJSON https://github.com/SwiftyJSON/SwiftyJSON.

## Installation

RONetworking is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RONetworking"
```

## How to use
Example Employees.json

```json
[
  {
    "firstName": "John",
    "lastName": "Doe",
    "age": 26
  },
  {
    "firstName": "Anna",
    "lastName": "Smith",
    "age": 30
  },
  {
    "firstName": "Peter",
    "lastName": "Jones",
    "age": 45
  }
]
```

As next step you have to create your data model (EmplyoeeContainer and Employee).

Employee.swift
````swift
class Employee : ROJSONObject {

    required init() {
        super.init();
    }

    required init(jsonData:AnyObject) {
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
```

Then to actually map the objects from the JSON response you only have to pass the data into the Employee class as param in the constructor. It does automatically create your data model.
```swift
var urlToJSON = "http://prine.ch/employeesWithout.json"

baseWebservice.getArray(urlToJSON, callback: { (status, employees:Array<Employee>) in
    for employee in employees {
        print("Firstname with Array: \(employee.firstname)")
    }
})
```

Or if you have an key containing the array you can use a container class:

EmployeeContainer.swift
```swift
class EmployeeContainer : ROJSONObject {
    required init() {
        super.init();
    }

    required init(jsonData:AnyObject) {
        super.init(jsonData: jsonData)
    }

    required init(jsonString: String) {
        super.init(jsonString:jsonString)
    }

    lazy var employees:[Employee] = {
        return Value<[Employee]>.getArray(self) as [Employee]
    }()
}
```

```swift
  var baseWebservice:BaseWebservice = BaseWebservice();

  var urlToJSON = "http://prine.ch/employeesWithout.json"

  baseWebservice.get(urlToJSON, callback: { (status, employeeContainer:EmployeeContainer) -> () in
      println(employeeContainer.employees[0].firstname)
      println(employeeContainer.employees[0].lastname)

      println("Firstname: " + employeeContainer.employees[0].firstname)
      println("Lastname: " + employeeContainer.employees[0].firstname)
      println("Age: \(employeeContainer.employees[0].age)")

  })
```


The console output looks then like the following:

```txt
John
Doe
Firstname: John
Lastname: John
Age: 26
```

## License

```
The MIT License (MIT)

Copyright (c) 2016 Robin Oster (http://prine.ch)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

## Author

Robin Oster, robin.oster@rascor.com
