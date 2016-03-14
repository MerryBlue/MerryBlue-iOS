//
//  TwitterManager.swift
//  MerryBlue
//
//  Created by Hiroto Takahashi on 2016/03/14.
//  Copyright © 2016年 Hiroto Takahashi. All rights reserved.
//

import Foundation
import TwitterKit
import SwiftyJSON

class TwitterManager {
    static let HOST = "https://api.twitter.com/1.1"
    
    static func getLists(userId: NSString) {
        let client = TWTRAPIClient()
        let statusesShowEndpont = HOST + "/lists/list.json"
        let params = [
            "user_id": userId
        ]
        var clientError: NSError?
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: statusesShowEndpont, parameters: params, error: &clientError)
        
        if let error = clientError {
            print("Error: \(error)")
            return
        }
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if (connectionError != nil) {
                print("Error: \(connectionError)")
                return
            }
            // var jsonError : NSError?
            // let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError)
            let json = JSON(data: data!)
            print(json)
        }
    }
    
    static func getLists() {
        guard let session = Twitter.sharedInstance().sessionStore.session() else {
            return
        }
        return getLists(session.userID)
    }
}
