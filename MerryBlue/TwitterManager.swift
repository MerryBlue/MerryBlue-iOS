import Foundation
import TwitterKit
import SwiftyJSON
import RxSwift

class TwitterManager {
    static let HOST = "https://api.twitter.com/1.1"
    static let LIST_FILTER_MEMBER_MAX_NUM = 50
    
    static func getLists(view: ListChooseViewController, userId: String = Twitter.sharedInstance().sessionStore.session()!.userID) -> Void {
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
            // let filteredList = filterList(lists)
            // view.setTableView(filteredList)
            
            view.setupTableView(lists)
            view.setSelectedCell()
            ListService.sharedInstance.updateLists(lists)
        }
    }
    
    static func filterList(lists: [TwitterList]) -> [TwitterList] {
        return lists.filter { $0.member_count <= LIST_FILTER_MEMBER_MAX_NUM }
    }
    
    static func sortUsersLastupdate(users: [TwitterUser]) -> [TwitterUser] {
        return users.sort({ return $0.compareLastTweetTo($1) })
    }
    
    static func sortUsersNewCount(users: [TwitterUser]) -> [TwitterUser] {
        return users.sort({ return $0.compareNewCountTo($1) })
    }
    
    // ---------- rx ------------ //
    static func requestUserProfile(var userID: String! = nil) -> Observable<TwitterUser> {
        if userID == nil {
            userID = self.getUserID()
        }
        return Observable.create { observer -> Disposable in
            _ = Twitter.sharedInstance()
                .rx_loadUserShow(userID, client: getClient())
                .subscribeNext { usersData in
                    let json = JSON(data: usersData)
                    observer.onNext(TwitterUser(json: json)!)
                }
            return AnonymousDisposable {}
        }
    }
    
    static func requestListMembers(listID: String, count: Int = 50) -> Observable<[TwitterUser]> {
        return Observable.create { observer -> Disposable in
            _ = Twitter.sharedInstance()
                .rx_loadListMembers(listID, client: getClient(), count: count)
                .subscribeNext { usersData in
                    let json = JSON(data: usersData)
                    let users = json["users"].array!.map({ return TwitterUser(json: $0)! })
                    observer.onNext(users)
                }
            return AnonymousDisposable {}
        }
    }
    
    static func requestLists(var ownerID: String! = nil) -> Observable<[TwitterList]> {
        if ownerID == nil {
            ownerID = self.getUserID()
        }
        return Observable.create { observer -> Disposable in
            _ = Twitter.sharedInstance()
                .rx_loadLists(ownerID, client: getClient())
                .subscribeNext { listsData in
                    let json = JSON(data: listsData)
                    let lists = json.map({ return TwitterList(jsonData: $1) })
                    observer.onNext(lists)
            }
            return AnonymousDisposable {}
        }
    }
    
    
    static func logoutUser() {
        guard let userID = getUserID() else {
            return
        }
        Twitter.sharedInstance().sessionStore.logOutUserID(userID)
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
