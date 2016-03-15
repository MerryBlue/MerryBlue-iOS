import Foundation
import TwitterKit
import SwiftyJSON

class TwitterManager {
    static let HOST = "https://api.twitter.com/1.1"
    static let LIST_FILTER_MEMBER_MAX_NUM = 50
    
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
            let filteredList = filterList(lists)
            view.setTableView(filteredList)
            view.setSelectedCell()
        }
    }
    
    static func filterList(lists: [TwitterList]) -> [TwitterList] {
        return lists.filter { $0.member_count <= LIST_FILTER_MEMBER_MAX_NUM }
    }
    
    static func getListUsers(view: HomeViewController, listId: NSString) -> Void {
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
            var users = [TwitterUser]()
            
            for userJson in json["users"].array! {
                users.append(TwitterUser(json: userJson)!)
            }
            let sortedUsers = sortUsers(users)
            view.setupListUsers(sortedUsers)
        }
    }
    
    static func sortUsers(users: [TwitterUser]) -> [TwitterUser] {
        return users.sort({
            guard let u1CreatedAt = $0.lastStatus.createdAt else {
                return false
            }
            guard let u2CreatedAt = $1.lastStatus.createdAt else {
                return true
            }
            return u1CreatedAt.compare(u2CreatedAt) == NSComparisonResult.OrderedDescending
        })
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
