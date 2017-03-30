//
//  BaseWebservice.swift
//  RASCOlibrary
//
//  Created by Robin Oster on 20/03/15.
//  Copyright (c) 2015 Rascor International AG. All rights reserved.
//




import Alamofire
import SwiftyJSON

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
        return "[\(String(describing: statusCode))]: \(errorType.rawValue)) - \(errorMessage)"
    }
}

class AccessTokenAdapter: RequestAdapter {
    private let username: String
    private let password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        let plainString = "\(self.username):\(self.password)"
        let plainData = (plainString as NSString).data(using: String.Encoding.utf8.rawValue)
        if let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) {
            urlRequest.setValue("Basic " + base64String, forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
}


open class BaseWebservice {
    
    
    /**
        Initial constructor
    */
    public init() {
        
    }
    
    /**
    Get method for fetching the data from the webservice (and optional with authentication)
    
    - parameter urlString:String:                            Urlto the REST webservice entry
    - parameter callback:(Int,: Any?) -> ()                  Callback block gets called when the operation has finished (including a status code and the created JSON Any? Tree)
    - parameter username:String?:                            Optional username for authentication (Default = nil)
    - parameter password:String?:                            Optional password for authentication (Default = nil)
    - parameter roError:((errorObject:ROError): -> ())?      Optional Error block which receives an ROError object containing additional information
    */
    open func get(_ urlString:String, callback:@escaping (Int, Any?) -> (), parameters:[String : Any]? = nil, headers:[String : String]? = nil, username:String? = nil, password:String? = nil, roError:((_ errorObject:ROError) -> ())? = nil) {
    
        let sessionManager = Alamofire.SessionManager.default
        
        // is there a username, the authorization header will be inserted an proper encoded
        if let username = username, let password = password {
            sessionManager.adapter = AccessTokenAdapter(username: username, password: password)
        }


        sessionManager.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if response.result.isSuccess {
                callback((response.response?.statusCode)!, response.result.value)
            } else {
                
                // If there is a response status code do not throw the error
                if let responseStatusCode = response.response?.statusCode {
                    callback(responseStatusCode, response.result.value)
                } else {
                    if let roError = roError {
                        roError(ROError(errorType: ROErrorType.RESPONSE_NOT_RECEIVED, statusCode:nil, errorMessage: "The webserver has not returned a response. There is no status code."))
                    }
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
    open func getROJSONObject<T:ROJSONObject>(_ urlString:String, callback: @escaping (Int, T) -> (), parameters:[String : Any]? = nil, headers:[String : String]? = nil, username:String? = nil,password:String? = nil, roError:((_ errorObject:ROError) -> ())? = nil) {
        
        let webserviceCallback = {(status:Int, response:Any?) -> () in
            if let response = response {
                callback(status, (T.self as T.Type).init(jsonData: response as AnyObject))
            } else {
                if let roError = roError {
                    roError(ROError(errorType: ROErrorType.RESPONSE_NOT_RECEIVED, statusCode:status, errorMessage: "The webserver has not returned a response. There is no status code."))
                }
            }
        }
        
        self.get(urlString, callback: webserviceCallback, parameters: parameters, headers:headers, username: username, password: password, roError:roError)
    }
    
    /**
     Generic get array method which creates automatically the Array containing ROJSONObjects from the given JSON response (and optional with authentication)
     
     - parameter urlString:String:                            Url to the REST webservice entry
     - parameter callback:(Int,: Array<T>) -> ()              Callback block gets called when the operation has finished (including a status code and the created Array of ROJSONObjects)
     - parameter username:String?:                            Optional username for authentication (Default = nil)
     - parameter password:String?:                            Optional password for authentication (Default = nil)
     - parameter roError:((errorObject:ROError): -> ())?      Optional Error block which receives an ROError object containing additional information
     */
    open func getArray<T:ROJSONObject>(_ urlString:String, callback: @escaping (Int, Array<T>) -> (), parameters:[String : Any]? = nil, headers:[String : String]? = nil, username:String? = nil, password:String? = nil, roError:((_ errorObject:ROError) -> ())? = nil) {
        let webserviceCallback = {(status:Int, response:Any?) -> () in
            var elements = [T]()
            
            if let jsonValue = response {
                let json = JSON(jsonValue)
                
                if let jsonArray = json.array {
                    for object in jsonArray {
                        let element = (T.self as T.Type).init()
                        
                        element.jsonData = object
                        elements.append(element)
                    }
                }
                
                callback(200, elements)
            } else {
                if let roError = roError {
                    roError(ROError(errorType: ROErrorType.RESPONSE_NOT_RECEIVED, statusCode:status, errorMessage: "The webserver has not returned a response. There is no status code."))
                }
                
                callback(404, [])
            }
        }
        
        self.get(urlString, callback: webserviceCallback, parameters:parameters, headers:headers, username:username, password:password, roError:roError)
    }
    
    
    /**
    Returns the untreated JSON string (not a JSON object tree)
    
    - parameter urlString:String                            Urlto the REST webservice entry
    - parameter callback:(Int, String) -> ()                Callback block gets called when the operation has finished (including a status code and the JSON string)
    - parameter roError:((errorObject:ROError) -> ())?      Optional Error block which receives an ROError object containing additional information
    */
    open func getString(_ urlString: String, callback: @escaping (Int, String) -> (), roError:((_ errorObject:ROError) -> ())? = nil) {
        
        // Make the asynchronous call
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.timeoutIntervalForRequest = 60
        sessionConfig.timeoutIntervalForResource = 60
        sessionConfig.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        let session = URLSession(configuration: sessionConfig)
        
        if let url = URL(string : urlString) {
            session.dataTask(with: url, completionHandler: { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    if(error == nil) {
                        callback(httpResponse.statusCode, NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String)
                    } else {
                        if let roError = roError {
                            roError(ROError(errorType: ROErrorType.REQUEST_ERROR, statusCode:httpResponse.statusCode, errorMessage: "Dealing with an invalid URL. Cannot send request to webserver"))
                        }
                    }
                }
            }).resume()
        } else {
            if let roError = roError {
                roError(ROError(errorType: ROErrorType.INVALID_URL_ERROR, statusCode:nil, errorMessage: "Dealing with an invalid URL. Cannot send request to webserver"))
            }
        }
    }
}
