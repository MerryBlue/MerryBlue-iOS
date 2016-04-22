import Foundation
import TwitterKit
import SwiftyJSON
import RxSwift

class TwitterManager {
    static let HOST = "https://api.twitter.com/1.1"
    static let listFilterMemberMaxNum = 50

    static func filterList(lists: [MBTwitterList]) -> [MBTwitterList] {
        return lists.filter { $0.memberCount <= listFilterMemberMaxNum }
    }

    static func sortUsersLastupdate(users: [TwitterUser]) -> [TwitterUser] {
        return users.sort { return $0.compareLastTweetTo($1) }
    }

    static func sortUsersNewCount(users: [TwitterUser]) -> [TwitterUser] {
        return users.sort { return $0.compareNewCountTo($1) }
    }

    static func sortUsersNewCountRev(users: [TwitterUser]) -> [TwitterUser] {
        return users.sort { return $0.compareNewCountRevTo($1) }
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

    static func requestMembers(list: MBTwitterList) -> Observable<[TwitterUser]> {
        switch list.listType {
        case .RecentFollow: return requestFriendUsers(getUserID())
        case .RecentFollower: return requestFollowerUsers(getUserID())
        case .Normal: return requestListMembers(list)
        }
    }

    static func requestUserTimeline(user: TwitterUser, count: Int = 30) -> Observable<[MBTweet]> {
        return Observable.create { observer -> Disposable in
            _ = Twitter.sharedInstance()
                .rxLoadUserTimeline(user.userID, count: count, beforeID: nil, client: getClient())
                .subscribeNext { (tlData: NSData) in
                    let json = JSON(data: tlData)
                    let tweets: [MBTweet] = json.map { MBTweet(json: $0.1)! }
                    observer.onNext(tweets)
                }
            return AnonymousDisposable {}
        }
    }

    static func requestTweetConversions(tweet: TWTRTweet) -> Observable<[MBTweet]> {
        return Observable.create { observer -> Disposable in
            _ = Twitter.sharedInstance()
                .rxLoadTweetConversions(tweet.tweetID, client: getClient())
                .subscribeNext { (tlData: NSData) in
                    let json = JSON(data: tlData)
                    let tweets: [MBTweet] = json.map { MBTweet(json: $0.1)! }
                    observer.onNext(tweets)
                }
            return AnonymousDisposable {}
        }
    }

    static func requestToggleLikeTweet(tweet: TWTRTweet) -> Observable<MBTweet> {
        if tweet.isLiked {
            return requestUnlikeTweet(tweet)
        } else {
            return requestLikeTweet(tweet)
        }
    }

    static func requestLikeTweet(tweet: TWTRTweet) -> Observable<MBTweet> {
        return Observable.create { observer -> Disposable in
            _ = Twitter.sharedInstance()
                .rxLoadLikeTweet(tweet.tweetID, client: getClient())
                .subscribeNext { (tlData: NSData) in
                    let json = JSON(data: tlData)
                    let tweet = MBTweet(json: json)!
                    observer.onNext(tweet)
                }
            return AnonymousDisposable {}
        }
    }

    static func requestUnlikeTweet(tweet: TWTRTweet) -> Observable<MBTweet> {
        return Observable.create { observer -> Disposable in
            _ = Twitter.sharedInstance()
                .rxLoadUnlikeTweet(tweet.tweetID, client: getClient())
                .subscribeNext { (tlData: NSData) in
                    let json = JSON(data: tlData)
                    let tweet = MBTweet(json: json)!
                    observer.onNext(tweet)
                }
            return AnonymousDisposable {}
        }
    }

    static func requestUserTimelineNext(user: TwitterUser, tweet: MBTweet, count: Int = 30) -> Observable<[MBTweet]> {
        return Observable.create { observer -> Disposable in
            _ = Twitter.sharedInstance()
                .rxLoadUserTimeline(user.userID, count: count, beforeID: String(Int(tweet.tweetID)! - 1), client: getClient())
                .subscribeNext { (tlData: NSData) in
                    let json = JSON(data: tlData)
                    let tweets: [MBTweet] = json.map { MBTweet(json: $0.1)! }
                    observer.onNext(tweets)
                }
            return AnonymousDisposable {}
        }
    }

    static func requestListMembers(list: MBTwitterList, count: Int = MBTwitterList.memberNumActiveMaxLimit) -> Observable<[TwitterUser]> {
        return Observable.create { observer -> Disposable in
            _ = Twitter.sharedInstance()
                .rxLoadListMembers(list.listID, client: getClient(), count: count)
                .subscribeNext { (usersData: NSData) in
                    let json = JSON(data: usersData)
                    let users = json["users"].array!.map { return TwitterUser(json: $0)! }
                    observer.onNext(users)
                }
            return AnonymousDisposable {}
        }
    }

    static func requestFriendUsers(userID: String, count: Int = 20) -> Observable<[TwitterUser]> {
        return Observable.create { observer -> Disposable in
            _ = Twitter.sharedInstance()
                .rxLoadFriendUsers(userID, client: getClient(), count: count)
                .subscribeNext { (usersData: NSData) in
                    let json = JSON(data: usersData)
                    let users = json["users"].array!.map { return TwitterUser(json: $0)! }
                    observer.onNext(users)
                }
            return AnonymousDisposable {}
        }
    }

    static func requestFollowerUsers(userID: String, count: Int = 20) -> Observable<[TwitterUser]> {
        return Observable.create { observer -> Disposable in
            _ = Twitter.sharedInstance()
                .rxLoadFollowerUsers(userID, client: getClient(), count: count)
                .subscribeNext { (usersData: NSData) in
                    let json = JSON(data: usersData)
                    let users = json["users"].array!.map { return TwitterUser(json: $0)! }
                    observer.onNext(users)
                }
            return AnonymousDisposable {}
        }
    }

    static func requestLists(ownerID: String) -> Observable<[MBTwitterList]> {
        return Observable.create { observer -> Disposable in
            _ = Twitter.sharedInstance()
                .rxLoadLists(ownerID, client: getClient())
                .subscribeNext { (listsData: NSData) in
                    let json = JSON(data: listsData)
                    let lists = json.map { return MBTwitterList(jsonData: $1) }
                    observer.onNext(lists)
            }
            return AnonymousDisposable {}
        }
    }

    static func isLogin() -> Bool {
        return Twitter.sharedInstance().sessionStore.session() != nil
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
