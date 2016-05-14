import Foundation
import TwitterKit
import SwiftyJSON
import RxSwift

public extension Twitter {

    enum RequestMethod: String {
        case GET = "GET"
        case POST = "POST"
    }
    public func APIHost() -> String {
        return "https://api.twitter.com/1.1/"
    }

    func requestMembers(list: MBTwitterList) -> Observable<[TwitterUser]> {
        switch list.listType {
        case .RecentFollow: return requestFriendUsers(TwitterManager.getUserID())
        case .RecentFollower: return requestFollowerUsers(TwitterManager.getUserID())
        case .Normal: return requestListMembers(list)

        }
    }

    public func requestUserProfile(userID: String) -> Observable<TwitterUser> {
        return Observable.create { observer -> Disposable in
            let parameters = ["user_id": userID]
            _ = self.rxURLRequestWithMethod(.GET, url: "users/show", parameters: parameters)
                .subscribe(
                    onNext: { data in
                        let json = JSON(data: data)
                        observer.onNext(TwitterUser(json: json)!)
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    public func requestUserTimeline(user: TwitterUser, count: Int = 30, beforeID: String! = nil) -> Observable<[MBTweet]> {
        var parameters = [
            "user_id": user.userID,
            "count": String(count),
            "include_entities": "true",
            "exclude_replies": "false"
        ]
        if let bid = beforeID {
            parameters["max_id"] = bid
        }
        return self.getTweetsRequest("statuses/user_timeline", parameters: parameters)
    }

    public func requestUserTimelineNext(user: TwitterUser, count: Int = 30, beforeTweet: MBTweet) -> Observable<[MBTweet]> {
        return Twitter.sharedInstance().requestUserTimeline(user, count: count, beforeID: String(Int(beforeTweet.tweetID)! - 1))
    }

    public func requestListTimeline(list: MBTwitterList, count: Int = 30, beforeID: String! = nil) -> Observable<[MBTweet]> {
        var parameters = [
            "list_id": list.listID,
            "count": String(count),
            "include_entities": "true",
            "include_rts": "true"
        ]
        if let bid = beforeID {
            parameters["max_id"] = bid
        }
        return self.getTweetsRequest("lists/statuses", parameters: parameters)
    }

    public func requestListTimelineNext(list: MBTwitterList, count: Int = 30, beforeTweet: MBTweet) -> Observable<[MBTweet]> {
        return Twitter.sharedInstance().requestListTimeline(list, count: count, beforeID: String(Int(beforeTweet.tweetID)! - 1))
    }

    public func requestToggleRetweet(tweet: TWTRTweet) -> Observable<MBTweet> {
        if tweet.isRetweeted {
            return requestUnretweet(tweet)
        } else {
            return requestRetweet(tweet)
        }
    }

    public func requestRetweet(tweet: TWTRTweet) -> Observable<MBTweet> {
        let parameters = [ "id": tweet.tweetID ]
        return self.postTweetRequest("statuses/retweet", parameters: parameters)
    }

    public func requestUnretweet(tweet: TWTRTweet) -> Observable<MBTweet> {
        let parameters = [ "id": tweet.tweetID ]
        return self.postTweetRequest("statuses/unretweet", parameters: parameters)
    }

    public func requestToggleLikeTweet(tweet: TWTRTweet) -> Observable<MBTweet> {
        if tweet.isLiked {
            return requestUnlikeTweet(tweet)
        } else {
            return requestLikeTweet(tweet)
        }
    }

    public func requestLikeTweet(tweet: TWTRTweet) -> Observable<MBTweet> {
        let parameters = [
            "id": tweet.tweetID,
            "include_entities": "false"
        ]
        return self.postTweetRequest("favorites/create", parameters: parameters)
    }

    public func requestUnlikeTweet(tweet: TWTRTweet) -> Observable<MBTweet> {
        let parameters = [
            "id": tweet.tweetID,
            "include_entities": "false"
        ]
        return self.postTweetRequest("favorites/destroy", parameters: parameters)
    }


    public func requestLists(ownerID: String) -> Observable<[MBTwitterList]> {
        return Observable.create { observer -> Disposable in
            let parameters = ["user_id": ownerID]
            _ = self.rxURLRequestWithMethod(.GET, url: "lists/list", parameters: parameters)
                .subscribe(
                    onNext: { data in
                        let json = JSON(data: data)
                        let lists = json.map { return MBTwitterList(jsonData: $1) }
                        observer.onNext(lists)
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    public func requestFriendUsers(userID: String, count: Int = 20) -> Observable<[TwitterUser]> {
        let parameters = [ "count": String(count) ]
        return self.getUsersRequest("friends/list", parameters: parameters)
    }

    public func requestFollowerUsers(userID: String, count: Int = 20) -> Observable<[TwitterUser]> {
        let parameters = [ "count": String(count) ]
        return self.getUsersRequest("followers/list", parameters: parameters)
    }

    public func requestListMembers(list: MBTwitterList, count: Int = MBTwitterList.memberNumActiveMaxLimit) -> Observable<[TwitterUser]> {
        let parameters = [
            "list_id": list.listID,
            "count": String(count)
        ]
        return self.getUsersRequest("lists/members", parameters: parameters)
    }

    public func requestSearchTweets(text: String,
                                    list: MBTwitterList?, beforeID: String?,
                                    filterImage: Bool = false,
                                    excludeRetweets: Bool = false,
                                    count: Int = MBTwitterList.memberNumActiveMaxLimit)
        -> Observable<[MBTweet]> {
        let q = TwitterSearchQueryBuilder(text: text)
        if filterImage {
            q.filterImage()
        }
        if excludeRetweets {
            q.excludeRT()
        }
        if let l = list {
            q.setList(l)
        }
        var parameters = [
            "q": q.build(),
            "count": String(count)
        ]
        if let bid = beforeID {
            parameters["max_id"] = bid
        }
        return self.getTweetsRequest("search/tweets", parameters: parameters, isStatusesWrapped: true)
    }

    public func requestListImageTweets(list: MBTwitterList, includeRT: Bool = false, beforeTweet: MBTweet? = nil) -> Observable<[MBTweet]> {
        var beforeID: String?
        if let bt = beforeTweet {
            beforeID = String(Int(bt.tweetID)! - 1)
        }
        return Twitter.sharedInstance().requestSearchTweets("", list: list, beforeID: beforeID, filterImage: true, excludeRetweets: !includeRT)
    }

    public func getTweetsRequest(url: String, parameters: [String: AnyObject], isStatusesWrapped: Bool = false) -> Observable<[MBTweet]> {
        return Observable.create { (observer) -> Disposable in
            _ = self.rxURLRequestWithMethod(.GET, url: url, parameters: parameters)
                .subscribe(
                    onNext: { data in
                        let json = JSON(data: data)
                        var statusesJson = json

                        if isStatusesWrapped {
                            statusesJson = json["statuses"]
                        }
                        let tweets: [MBTweet] = statusesJson.map { MBTweet(json: $0.1)! }
                        observer.onNext(tweets)
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    public func getUsersRequest(url: String, parameters: [String: AnyObject]) -> Observable<[TwitterUser]> {
        return Observable.create { (observer) -> Disposable in
            _ = self.rxURLRequestWithMethod(.GET, url: url, parameters: parameters)
                .subscribe(
                    onNext: { data in
                        let json = JSON(data: data)
                        let users = json["users"].array!.map { return TwitterUser(json: $0)! }
                        observer.onNext(users)
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    public func postTweetRequest(url: String, parameters: [String: AnyObject]) -> Observable<MBTweet> {
        return Observable.create { (observer) -> Disposable in
            _ = self.rxURLRequestWithMethod(.POST, url: url, parameters: parameters)
                .subscribe(
                    onNext: { data in
                        let json = JSON(data: data)
                        let tweet = MBTweet(json: json)!
                        observer.onNext(tweet)
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    public func rxURLRequestWithMethod(method: RequestMethod, url: String, parameters: [String: AnyObject])
        -> Observable<NSData> {
            return Observable.create { observer -> Disposable in
                let client = TwitterManager.getClient()
                let request = client.URLRequestWithMethod(method.rawValue, URL: "\(self.APIHost())\(url).json", parameters: parameters, error: nil)
                client.sendTwitterRequest(request) { response, data, connectionError in
                    guard let data = data else {
                        observer.onError(connectionError!)
                        return
                    }
                    observer.onNext(data)
                    observer.onCompleted()
                }
                return AnonymousDisposable { }
            }
    }

}
