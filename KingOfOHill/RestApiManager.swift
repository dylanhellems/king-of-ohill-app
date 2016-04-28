//
//  RestApiManager.swift
//  KingOfOHill
//
//  Created by Dylan Hellems on 4/2/16.
//  Copyright © 2016 Dylan Hellems. All rights reserved.
//
//  Based off tutorial at https://grokswift.com/simple-rest-with-swift/

import Foundation

class RestApiManager: NSObject {

    var urlBase : String = "https://king-of-ohill-web.herokuapp.com/"
    var request : NSURLRequest = NSURLRequest()
    
    func get_leaderboards(callback: (Dictionary<String, AnyObject>) -> ()) {
        let endpoint = urlBase + "get_leaderboards/"
        
        get(endpoint, callback: callback)
    }
    
    func get(endpoint: String, callback: (Dictionary<String, AnyObject>) -> ()) {
        
        guard let url = NSURL(string: endpoint) else {
            print("Error: cannot create URL")
            return
        }
        let request = NSURLRequest(URL: url)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            guard error == nil else {
                print("error calling GET on /\(endpoint)")
                print(error)
                return
            }
            
            // parse the result as JSON, since that's what the API provides
            let post: NSDictionary
            
            do {
                post = try NSJSONSerialization.JSONObjectWithData(responseData,
                    options: []) as! NSDictionary
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            
            callback(post as! Dictionary)
            
            // now we have the post, let's just print it to prove we can access it
            print("The post is: " + post.description)
            
            // the post object is a dictionary
            if let postResult = post["result"] as? String {
                print("The result is: " + postResult)
            }
            
            if let postMessage = post["message"] as? String {
                print("The message is: " + postMessage)
            }
            
        })
        
        task.resume()
        
    }
    
    func add_nickname(nickname: String, callback: (Dictionary<String, AnyObject>) -> ()) {
        let endpoint = urlBase + "add_nickname/"
        
        post(endpoint, params: [("name", nickname)], callback: callback)
    }
    
    func validate_nickname(nickname: String, id: String, callback: (Dictionary<String, AnyObject>) -> ()) {
        let endpoint = urlBase + "validate_nickname/"
        
        post(endpoint, params: [("name", nickname), ("id", id)], callback: callback)
    }
    
    func add_score(nickname: String, score: String, time: String, location: String, callback: (Dictionary<String, AnyObject>) -> ()) {
        let endpoint = urlBase + "add_score/"
        
        post(endpoint, params: [("nickname", nickname), ("score", score), ("timeframe", time), ("location", location)], callback: callback)
        
    }
    
    func post(endpoint: String, params: [(String, String)], callback: (Dictionary<String, AnyObject>) -> ()) {
        
        guard let url = NSURL(string: endpoint) else {
            print("Error: cannot create URL")
            return
        }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        var bodyData = ""
        for (key, value) in params {
            print(key + ": " + value)
            let scapedKey = key.stringByAddingPercentEncodingWithAllowedCharacters(
                .URLHostAllowedCharacterSet())!
            let scapedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(
                .URLHostAllowedCharacterSet())!
            bodyData += "\(scapedKey)=\(scapedValue)&"
        }
    
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)

        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            guard error == nil else {
                print("error calling POST on /\(endpoint)")
                print(error)
                return
            }
            
            // parse the result as JSON, since that's what the API provides
            let post: NSDictionary
            
            do {
                post = try NSJSONSerialization.JSONObjectWithData(responseData,
                    options: []) as! NSDictionary
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            
            callback(post as! Dictionary)
            
            // now we have the post, let's just print it to prove we can access it
            print("The post is: " + post.description)
            
            // the post object is a dictionary
            if let postResult = post["result"] as? String {
                print("The result is: " + postResult)
            }
            
            if let postMessage = post["message"] as? String {
                print("The message is: " + postMessage)
            }
            
        })
        
        task.resume()
    }
}
