//
//  JSONObject.swift
//  RASCOcloud
//
//  Created by Robin Oster on 02/07/14.
//  Copyright (c) 2014 Robin Oster. All rights reserved.
//

import Foundation
import SwiftyJSON

public class ROJSONObject {
    
    public var jsonData:JSON

    public required init() {
        jsonData = []
    }
    
    public required init(jsonData:AnyObject) {
        self.jsonData = JSON(jsonData)
    }
    
    public required init(jsonString:String) {
        var data = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var error:NSError?
        
        if let dataTemp = data {
            var json:AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error)
            
            if (error != nil) {
                // println("Something went wrong during the creation of the json dict \(error)")
            } else {
                self.jsonData = JSON(json!)
                return
            }
        }
        
        self.jsonData = JSON("")
    }
    
    public func getJSONValue(key:String) -> JSON {
        return jsonData[key]
    }
    
    public func getValue(key:String) -> AnyObject {
        
        var jsonValue = jsonData[key]
        
        if (jsonValue.type == Type.Unknown || jsonValue.type == Type.Null) {
            return "null"
        }

        return jsonData[key].object
    }
    
    public func getArray<T : ROJSONObject>(key:String) -> [T] {
        var elements = [T]()
        
        for jsonValue in getJSONValue(key).array! {
            var element = (T.self as T.Type)()
            
            element.jsonData = jsonValue
            elements.append(element)
        }
        
        return elements
    }
    
    func getDate(key:String, dateFormatter:NSDateFormatter? = nil) -> NSDate? {
        
        if let jsonString = jsonData[key].string {
            return parseDate(jsonString)
        }
        
        return nil
    }
    
    func parseDate(string:String, dateFormatter:NSDateFormatter? = nil) -> NSDate? {
        // Check if a dateParser has been passed or not
        if(dateFormatter != nil) {
            if let parsedDate = dateFormatter!.dateFromString(string) {
                return parsedDate
            } else {
                return nil
            }
        } else {
            // If there hasnt been passed a specific NSDateFormatter us the ISO8601 standard
            var isoDateFormats = ["yyyy-MM-dd'T'HH:mm:ssZZZ",
                "yyyy-MM-dd'T'HH:mm:ssZZZZ",
                "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"]
            
            var isoDateFormatter = NSDateFormatter()
            
            for isoDateFormat in isoDateFormats {
                isoDateFormatter.dateFormat = isoDateFormat
                
                if let parsedDate = isoDateFormatter.dateFromString(string) {
                    return parsedDate
                }
            }
        }
        
        return nil
    }
}



public class Value<T> {
    public class func get(rojsonobject:ROJSONObject, key:String) -> T {
        return rojsonobject.getValue(key) as! T
    }
    
    public class func getArray<T : ROJSONObject>(rojsonobject:ROJSONObject, key:String? = nil) -> [T] {
        
        // If there is a key given fetch the array from the dictionary directly if not fetch all objects and pack it into an array
        if let dictKey = key {
            return rojsonobject.getArray(dictKey) as [T]
        } else {
            var objects = [T]()
            
            for jsonValue in rojsonobject.jsonData.array! {
                var object = (T.self as T.Type)()
                object.jsonData = jsonValue
                objects.append(object)
            }
            
            return objects
        }
    }
    
    public class func getDate(rojsonobject:ROJSONObject, key:String, dateFormatter:NSDateFormatter? = nil) -> NSDate? {
        if let dateParsed = rojsonobject.getDate(key, dateFormatter:dateFormatter) {
            return dateParsed
        } else {
            println("Could not parse the date correctly. Returning nil")
            return nil
        }
    }
}