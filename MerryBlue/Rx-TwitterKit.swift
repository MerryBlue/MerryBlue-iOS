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

    func requestMembers(_ list: MBTwitterList) -> Observable<[TwitterUser]> {
        switch list.listType {
        case .RecentFollow: return requestFriendUsers(TwitterManager.getUserID())
        case .RecentFollower: return requestFollowerUsers(TwitterManager.getUserID())
        case .Normal: return requestListMembers(list)
        }
    }

    func requestMembersLastTweets(_ list: MBTwitterList) -> Observable<[MBTweet]> {
        return Observable.create { observer -> Disposable in
            _ = self.requestMembers(list)
                .subscribe(
                    onNext: { (users: [TwitterUser]) in
                        let tweets = users.map({ (user: TwitterUser) -> MBTweet in
                            let tweet = user.lastStatus
                            return tweet!
                        })
                        observer.onNext(TwitterManager.sortTweetsLastupdate(tweets))
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    public func requestUserProfile(_ userID: String) -> Observable<TwitterUser> {
        return Observable.create { observer -> Disposable in
            let parameters = ["user_id": userID]
            _ = self.rxURLRequestWithMethod(.GET, url: "users/show", parameters: parameters as [String : AnyObject])
                .subscribe(
                    onNext: { data in
                        let json = JSON(data: data as Data)
                        observer.onNext(TwitterUser(json: json)!)
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    public func requestUserTimeline(_ user: TwitterUser, count: Int = 30, beforeID: String! = nil) -> Observable<[MBTweet]> {
        var parameters = [
            "user_id": user.userID,
            "count": String(count),
            "include_entities": "true",
            "exclude_replies": "false"
        ]
        if let bid = beforeID {
            parameters["max_id"] = bid
        }
        return self.getTweetsRequest("statuses/user_timeline", parameters: parameters as [String : AnyObject])
    }

    public func requestUserTimelineNext(_ user: TwitterUser, count: Int = 30, beforeTweet: MBTweet) -> Observable<[MBTweet]> {
        return Twitter.sharedInstance().requestUserTimeline(user, count: count, beforeID: String(Int(beforeTweet.tweetID)! - 1))
    }


    public func requestListTimeline(_ list: MBTwitterList, count: Int = 30, beforeID: String! = nil, excludeRetweets: Bool = false) -> Observable<[MBTweet]> {
        var parameters = [
            "list_id": list.listID,
            "count": String(count),
            "include_entities": "true",
            "include_rts": excludeRetweets ? "false" : "true"
        ]
        if let bid = beforeID {
            parameters["max_id"] = bid
        }
        return self.getTweetsRequest("lists/statuses", parameters: parameters as [String : AnyObject])
    }

    public func requestListTimelineNext(_ list: MBTwitterList, count: Int = 30, beforeTweet: MBTweet) -> Observable<[MBTweet]> {
        return Twitter.sharedInstance().requestListTimeline(list, count: count, beforeID: String(Int(beforeTweet.tweetID)! - 1))
    }

    public func requestToggleRetweet(_ tweet: TWTRTweet) -> Observable<MBTweet> {
        if tweet.isRetweeted {
            return requestUnretweet(tweet)
        } else {
            return requestRetweet(tweet)
        }
    }

    public func requestRetweet(_ tweet: TWTRTweet) -> Observable<MBTweet> {
        let parameters = [ "id": tweet.tweetID ]
        return self.postTweetRequest("statuses/retweet", parameters: parameters as [String : AnyObject])
    }

    public func requestUnretweet(_ tweet: TWTRTweet) -> Observable<MBTweet> {
        let parameters = [ "id": tweet.tweetID ]
        return self.postTweetRequest("statuses/unretweet", parameters: parameters as [String : AnyObject])
    }

    public func requestToggleLikeTweet(_ tweet: TWTRTweet) -> Observable<MBTweet> {
        if tweet.isLiked {
            return requestUnlikeTweet(tweet)
        } else {
            return requestLikeTweet(tweet)
        }
    }

    public func requestLikeTweet(_ tweet: TWTRTweet) -> Observable<MBTweet> {
        let parameters = [
            "id": tweet.tweetID,
            "include_entities": "false"
        ]
        return self.postTweetRequest("favorites/create", parameters: parameters as [String : AnyObject])
    }

    public func requestUnlikeTweet(_ tweet: TWTRTweet) -> Observable<MBTweet> {
        let parameters = [
            "id": tweet.tweetID,
            "include_entities": "false"
        ]
        return self.postTweetRequest("favorites/destroy", parameters: parameters as [String : AnyObject])
    }


    public func requestLists(_ ownerID: String) -> Observable<[MBTwitterList]> {
        return Observable.create { observer -> Disposable in
            let parameters = ["user_id": ownerID]
            _ = self.rxURLRequestWithMethod(.GET, url: "lists/list", parameters: parameters as [String : AnyObject])
                .subscribe(
                    onNext: { data in
                        let json = JSON(data: data as Data)
                        let lists = json.map { return MBTwitterList(jsonData: $1) }
                        observer.onNext(lists)
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    public func requestFriendUsers(_ userID: String, count: Int = 20) -> Observable<[TwitterUser]> {
        let parameters = [
            "count": String(count),
            "include_user_entities": "true"
        ]
        return self.getUsersRequest("friends/list", parameters: parameters as [String : AnyObject])
    }

    public func requestFollowerUsers(_ userID: String, count: Int = 20) -> Observable<[TwitterUser]> {
        let parameters = [
            "count": String(count)
        ]
        return self.getUsersRequest("followers/list", parameters: parameters as [String : AnyObject])
    }

    public func requestListMembers(_ list: MBTwitterList, count: Int = MBTwitterList.memberNumActiveMaxLimit) -> Observable<[TwitterUser]> {
        let parameters = [
            "list_id": list.listID,
            "count": String(count)
        ]
        return self.getUsersRequest("lists/members", parameters: parameters as [String : AnyObject])
    }

    public func requestSearchTweets(_ text: String,
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
        return self.getTweetsRequest("search/tweets", parameters: parameters as [String : AnyObject], isStatusesWrapped: true)
    }

    public func requestListImageTweets(_ list: MBTwitterList, includeRT: Bool = false, beforeTweet: MBTweet? = nil) -> Observable<[MBTweet]> {
        var beforeID: String?
        if let bt = beforeTweet {
            beforeID = String(Int(bt.tweetID)! - 1)
        }
        if list.isPrivate {
            return Twitter.sharedInstance().requestListTimeline(list, count: 200, beforeID: beforeID, excludeRetweets: !includeRT)
        }
        return Twitter.sharedInstance().requestSearchTweets("", list: list, beforeID: beforeID, filterImage: true, excludeRetweets: !includeRT)
    }

    public func getTweetsRequest(_ url: String, parameters: [String: AnyObject], isStatusesWrapped: Bool = false) -> Observable<[MBTweet]> {
        return Observable.create { (observer) -> Disposable in
            _ = self.rxURLRequestWithMethod(.GET, url: url, parameters: parameters)
                .subscribe(
                    onNext: { data in
                        let json = JSON(data: data as Data)
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

    public func getUsersRequest(_ url: String, parameters: [String: AnyObject]) -> Observable<[TwitterUser]> {
        return Observable.create { (observer) -> Disposable in
            _ = self.rxURLRequestWithMethod(.GET, url: url, parameters: parameters)
                .subscribe(
                    onNext: { data in
                        let json = JSON(data: data as Data)
                        let users = json["users"].array!.map { return TwitterUser(json: $0)! }
                        observer.onNext(users)
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    public func postTweetRequest(_ url: String, parameters: [String: AnyObject]) -> Observable<MBTweet> {
        return Observable.create { (observer) -> Disposable in
            _ = self.rxURLRequestWithMethod(.POST, url: url, parameters: parameters)
                .subscribe(
                    onNext: { data in
                        let json = JSON(data: data as Data)
                        let tweet = MBTweet(json: json)!
                        observer.onNext(tweet)
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    public func rxURLRequestWithMethod(_ method: RequestMethod, url: String, parameters: [String: AnyObject])
        -> Observable<NSData> {
            return Observable.create { observer -> Disposable in
                let client = TwitterManager.getClient()
                let request = client.urlRequest(withMethod: method.rawValue, url: "\(self.APIHost())\(url).json", parameters: parameters, error: nil)
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
