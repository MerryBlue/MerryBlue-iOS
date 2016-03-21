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
    
    static func sortUsers(users: [TwitterUser]) -> [TwitterUser] {
        return users.sort({
            guard let u1Status = $0.lastStatus else {
                return false
            }
            guard let u2Status = $1.lastStatus else {
                return true
            }
            return u1Status.createdAt.compare(u2Status.createdAt) == NSComparisonResult.OrderedDescending
        })
    }
    
    // ---------- rx ------------ //
    static func requestProfileInformation() -> Observable<TWTRUser> {
        return Observable.create { observer -> Disposable in
            Twitter.sharedInstance()
                .rx_loadUserWithID(getUserID(), client: getClient())
                .subscribe(onNext: { user in
                    // self.session.user = user
                    observer.onNext(user)
                    observer.onCompleted()
                    }, onError: { error in
                        print("Failed: \(error)")
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(DisposeBag())
            // .addDisposableTo(self.rx_disposeBag)
            return AnonymousDisposable {}
        }
    }
    
    static func requestListMembers(listID: String, count: Int = 50) -> Observable<[TwitterUser]> {
        return Observable.create { observer -> Disposable in
            Twitter.sharedInstance()
                .rx_loadListMembers(listID, client: getClient(), count: count)
                .subscribeNext { usersData in
                    let json = JSON(data: usersData)
                    var users = [TwitterUser]()
                    
                    for userJson in json["users"].array! {
                        users.append(TwitterUser(json: userJson)!)
                    }
                    let sortedUsers = sortUsers(users)
                    observer.onNext(sortedUsers)
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
