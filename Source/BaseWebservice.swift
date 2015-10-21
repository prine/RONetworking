//
//  BaseWebservice.swift
//  RASCOlibrary
//
//  Created by Robin Oster on 20/03/15.
//  Copyright (c) 2015 Rascor International AG. All rights reserved.
//

import Alamofire

public enum ROErrorType:String {
    case REQUEST_ERROR = "Request error"
    case INVALID_URL_ERROR = "Invalid url error"
    case RESPONSE_NOT_RECEIVED = "Response not received"
}

public struct ROError {
    var errorType:ROErrorType
    var statusCode:Int?
    var errorMessage:String
    
    public func log() -> String {
        return "[\(statusCode)]: \(errorType.rawValue)) - \(errorMessage)"
    }
}

public class BaseWebservice {
    
    
    /**
        Initial constructor
    */
    public init() {
        
    }
    
    /**
    Get method for fetching the data from the webservice (and optional with authentication)
    
    - parameter urlString:String:                            Urlto the REST webservice entry
    - parameter callback:(Int,: AnyObject?) -> ()            Callback block gets called when the operation has finished (including a status code and the created JSON AnyObject? Tree)
    - parameter username:String?:                            Optional username for authentication (Default = nil)
    - parameter password:String?:                            Optional password for authentication (Default = nil)
    - parameter roError:((errorObject:ROError): -> ())?      Optional Error block which receives an ROError object containing additional information
    */
    public func get(urlString:String, callback:(Int, AnyObject?) -> (), parameters:[String : AnyObject!]? = nil, username:String? = nil, password:String? = nil, roError:((errorObject:ROError) -> ())? = nil) {
        
        if (username != nil && password != nil) { // is there a username, the authorization header will be inserted an proper encoded
            
            let plainString = "\(username!):\(password!)"
            let plainData = (plainString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            
            Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["Authorization": "Basic " + base64String!]
        }
        
        Alamofire.request(.GET, urlString, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                callback((response.response?.statusCode)!, response.result.value)
            } else {
                if let roError = roError {
                    roError(errorObject:ROError(errorType: ROErrorType.RESPONSE_NOT_RECEIVED, statusCode:nil, errorMessage: "The webserver has not returned a response. There is no status code."))
                }
            }
        }
    }
    
    /**
    Generic get method which creates automatically the ROJSONObjects from the given JSON response (and optional with authentication)
    
    - parameter urlString:String:                            Url to the REST webservice entry
    - parameter callback:(Int,: T) -> ()                     Callback block gets called when the operation has finished (including a status code and the created ROJSONObject)
    - parameter username:String?:                            Optional username for authentication (Default = nil)
    - parameter password:String?:                            Optional password for authentication (Default = nil)
    - parameter roError:((errorObject:ROError): -> ())?      Optional Error block which receives an ROError object containing additional information
    */
    public func getROJSONObject<T:ROJSONObject>(urlString:String, callback: (Int, T) -> (), parameters:[String : AnyObject!]? = nil, username:String? = nil,password:String? = nil, roError:((errorObject:ROError) -> ())? = nil) {
        
        let webserviceCallback = {(status:Int, response:AnyObject?) -> () in
            if let response:AnyObject = response {
                callback(status, (T.self as T.Type).init(jsonData: response))
            } else {
                if let roError = roError {
                    roError(errorObject:ROError(errorType: ROErrorType.RESPONSE_NOT_RECEIVED, statusCode:status, errorMessage: "The webserver has not returned a response. There is no status code."))
                }
            }

        }
        
        self.get(urlString, callback: webserviceCallback, parameters: parameters, username: username, password: password, roError:roError)
    }
    
    
    /**
    Returns the untreated JSON string (not a JSON object tree)
    
    - parameter urlString:String                            Urlto the REST webservice entry
    - parameter callback:(Int, String) -> ()                Callback block gets called when the operation has finished (including a status code and the JSON string)
    - parameter roError:((errorObject:ROError) -> ())?      Optional Error block which receives an ROError object containing additional information
    */
    public func getString(urlString: String, callback: (Int, String) -> (), roError:((errorObject:ROError) -> ())? = nil) {
        
        // Make the asynchronous call
        let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfig.timeoutIntervalForRequest = 60
        sessionConfig.timeoutIntervalForResource = 60
        sessionConfig.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        let session = NSURLSession(configuration: sessionConfig)
        
        let completionHandler = { (data: NSData?, urlResponse: NSURLResponse?, error: NSError?) -> () in
            
            if let httpResponse = urlResponse as? NSHTTPURLResponse {
                if(error == nil) {
                    callback(httpResponse.statusCode, NSString(data: data!, encoding: NSUTF8StringEncoding)! as String)
                } else {
                    if let roError = roError {
                        roError(errorObject:ROError(errorType: ROErrorType.REQUEST_ERROR, statusCode:httpResponse.statusCode, errorMessage: "Dealing with an invalid URL. Cannot send request to webserver"))
                    }
                }
            }
        }
        
        let url: NSURL? = NSURL(string : urlString)
        
        if let _ = url {
            session.dataTaskWithURL(url!, completionHandler: completionHandler).resume()
        } else {
            if let roError = roError {
                roError(errorObject:ROError(errorType: ROErrorType.INVALID_URL_ERROR, statusCode:nil, errorMessage: "Dealing with an invalid URL. Cannot send request to webserver"))
            }
        }
    }
    
}