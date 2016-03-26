import Foundation
import TwitterKit
import SwiftyJSON
import RxSwift

class TwitterManager {
    static let HOST = "https://api.twitter.com/1.1"
    static let listFilterMemberMaxNum = 50

    static func filterList(lists: [TwitterList]) -> [TwitterList] {
        return lists.filter { $0.memberCount <= listFilterMemberMaxNum }
    }

    static func sortUsersLastupdate(users: [TwitterUser]) -> [TwitterUser] {
        return users.sort { return $0.compareLastTweetTo($1) }
    }

    static func sortUsersNewCount(users: [TwitterUser]) -> [TwitterUser] {
        return users.sort { return $0.compareNewCountTo($1) }
    }

    // ---------- rx ------------ //
    static func requestUserProfile(userID: String) -> Observable<TwitterUser> {
        return Observable.create { observer -> Disposable in
            _ = Twitter.sharedInstance()
                .rxLoadUserShow(userID, client: getClient())
                .subscribeNext { (usersData: NSData) in
                    let json = JSON(data: usersData)
                    observer.onNext(TwitterUser(json: json)!)
                }
            return AnonymousDisposable {}
        }
    }

    static func requestListMembers(listID: String, count: Int = 50) -> Observable<[TwitterUser]> {
        return Observable.create { observer -> Disposable in
            _ = Twitter.sharedInstance()
                .rxLoadListMembers(listID, client: getClient(), count: count)
                .subscribeNext { (usersData: NSData) in
                    let json = JSON(data: usersData)
                    let users = json["users"].array!.map { return TwitterUser(json: $0)! }
                    observer.onNext(users)
                }
            return AnonymousDisposable {}
        }
    }

    static func requestLists(ownerID: String) -> Observable<[TwitterList]> {
        return Observable.create { observer -> Disposable in
            _ = Twitter.sharedInstance()
                .rxLoadLists(ownerID, client: getClient())
                .subscribeNext { (listsData: NSData) in
                    let json = JSON(data: listsData)
                    let lists = json.map { return TwitterList(jsonData: $1) }
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
            // print("Error: not authorized")
            return nil
        }
        return session.userID
    }

}
