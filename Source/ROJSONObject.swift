//
//  JSONObject.swift
//  RASCOcloud
//
//  Created by Robin Oster on 02/07/14.
//  Copyright (c) 2014 Robin Oster. All rights reserved.
//

import Foundation
import SwiftyJSON3

open class ROJSONObject {
    
    open var jsonData:JSON

    public required init() {
        jsonData = []
    }
    
    public required init(jsonData:Any) {
        self.jsonData = JSON(jsonData)
    }
    
    public required init(jsonString:String) {
        let data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false)
        var error:NSError?
        
        if let _ = data {
            var json:Any?
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            } catch let error1 as NSError {
                error = error1
                json = nil
            }
            
            if (error != nil) {
                // println("Something went wrong during the creation of the json dict \(error)")
            } else {
                self.jsonData = JSON(json!)
                return
            }
        }
        
        self.jsonData = JSON("")
    }
    
    open func getJSONValue(_ key:String) -> JSON {
        return jsonData[key]
    }
    
    open func getValue(_ key:String) -> Any {
        
        let jsonValue = jsonData[key]
        
        if (jsonValue.type == Type.unknown || jsonValue.type == Type.null) {
            return "null"
        }

        return jsonData[key].object
    }
    
    open func getArray<T : ROJSONObject>(_ key:String) -> [T] {
        var elements = [T]()
        
        for jsonValue in getJSONValue(key).array! {
            let element = (T.self as T.Type).init()
            
            element.jsonData = jsonValue
            elements.append(element)
        }
        
        return elements
    }
    
    func getDate(_ key:String, dateFormatter:DateFormatter? = nil) -> Date? {
        
        if let jsonString = jsonData[key].string {
            return parseDate(jsonString)
        }
        
        return nil
    }
    
    func parseDate(_ string:String, dateFormatter:DateFormatter? = nil) -> Date? {
        // Check if a dateParser has been passed or not
        if(dateFormatter != nil) {
            if let parsedDate = dateFormatter!.date(from: string) {
                return parsedDate
            } else {
                return nil
            }
        } else {
            // If there hasnt been passed a specific NSDateFormatter us the ISO8601 standard
            let isoDateFormats = ["yyyy-MM-dd'T'HH:mm:ssZZZ",
                "yyyy-MM-dd'T'HH:mm:ssZZZZ",
                "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"]
            
            let isoDateFormatter = DateFormatter()
            
            for isoDateFormat in isoDateFormats {
                isoDateFormatter.dateFormat = isoDateFormat
                
                if let parsedDate = isoDateFormatter.date(from: string) {
                    return parsedDate
                }
            }
        }
        
        return nil
    }
}



open class Value<T> {
    open class func get(_ rojsonobject:ROJSONObject, key:String) -> T {
        return rojsonobject.getValue(key) as! T
    }
    
    open class func getArray<T : ROJSONObject>(_ rojsonobject:ROJSONObject, key:String? = nil) -> [T] {
        
        // If there is a key given fetch the array from the dictionary directly if not fetch all objects and pack it into an array
        if let dictKey = key {
            return rojsonobject.getArray(dictKey) as [T]
        } else {
            var objects = [T]()
            
            for jsonValue in rojsonobject.jsonData.array! {
                let object = (T.self as T.Type).init()
                object.jsonData = jsonValue
                objects.append(object)
            }
            
            return objects
        }
    }
    
    open class func getDate(_ rojsonobject:ROJSONObject, key:String, dateFormatter:DateFormatter? = nil) -> Date? {
        if let dateParsed = rojsonobject.getDate(key, dateFormatter:dateFormatter) {
            return dateParsed
        } else {
            print("Could not parse the date correctly. Returning nil")
            return nil
        }
    }
}
