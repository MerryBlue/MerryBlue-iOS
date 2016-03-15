import Foundation
import TwitterKit
import SwiftyJSON

class TwitterManager {
    static let HOST = "https://api.twitter.com/1.1"
    
    static func getLists(view: ListChooseViewController, userId: NSString = Twitter.sharedInstance().sessionStore.session()!.userID) -> Void {
        let client = getClient()
        let statusesShowEndpont = HOST + "/lists/list.json"
        let params = [ "user_id": userId ]
        var clientError: NSError?
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: statusesShowEndpont, parameters: params, error: &clientError)
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if (connectionError != nil) {
                print("Error: \(connectionError)")
                return
            }
            let json = JSON(data: data!)
            var lists: [TwitterList] = []
            
            for (_, datum) in json {
                lists.append(TwitterList(jsonData: datum))
            }
            view.setTableView(lists)
            view.setSelectedCell()
        }
    }
    
    static func getListUsers(listId: NSString) -> Void {
        let client = getClient()
        let statusesShowEndpont = HOST + "/lists/members.json"
        let params = [ "list_id": listId ]
        var clientError: NSError?
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: statusesShowEndpont, parameters: params, error: &clientError)
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if (connectionError != nil) {
                print("Error: \(connectionError)")
                return
            }
            let json = JSON(data: data!)
            var users: [TWTRUser] = []
            
            for userJson in json["users"].array! {
                let user = TwitterUser(JSONDictionary: userJson.dictionaryObject)
                user.lastStatus = TWTRTweet(JSONDictionary: userJson["status"].dictionaryObject)
                users.append(user)
            }
            // TODO: dispatch
        }
    }
    
    static func getClient() -> TWTRAPIClient {
        return TWTRAPIClient(userID: getUserID())
    }
    
    static func getUserID() -> String! {
        guard let session = Twitter.sharedInstance().sessionStore.session() else {
            print("Error: not authorized")
            return nil
        }
        return session.userID
    }
}
