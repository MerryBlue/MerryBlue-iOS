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
            _ = self.rxURLRequestWithMethod(.GET, url: "users/show", parameters: parameters, client: TwitterManager.getClient())
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
        return Observable.create { observer -> Disposable in
            var parameters = [
                "user_id": user.userID,
                "count": String(count),
                "include_entities": "true",
                "exclude_replies": "false"
            ]
            if let bid = beforeID {
                parameters["max_id"] = bid
            }
            _ = self.rxURLRequestWithMethod(.GET, url: "statuses/user_timeline", parameters: parameters, client: TwitterManager.getClient())
                .subscribe(
                    onNext: { data in
                        let json = JSON(data: data)
                        let tweets: [MBTweet] = json.map { MBTweet(json: $0.1)! }
                        observer.onNext(tweets)
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    public func requestUserTimelineNext(user: TwitterUser, count: Int = 30, beforeTweet: MBTweet) -> Observable<[MBTweet]> {
        return Twitter.sharedInstance().requestUserTimeline(user, count: count, beforeID: beforeTweet.tweetID)
    }

    public func requestListTimeline(list: MBTwitterList, count: Int = 30, beforeID: String! = nil) -> Observable<[MBTweet]> {
        return Observable.create { observer -> Disposable in
            var parameters = [
                "list_id": list.listID,
                "count": String(count),
                "include_entities": "true",
                "include_rts": "true"
            ]
            if let beforeID = beforeID {
                parameters["beforeID"] = beforeID
            }
            _ = self.rxURLRequestWithMethod(.GET, url: "lists/statuses", parameters: parameters, client: TwitterManager.getClient())
                .subscribe(
                    onNext: { data in
                        let json = JSON(data: data)
                        let tweets: [MBTweet] = json.map { MBTweet(json: $0.1)! }
                        observer.onNext(tweets)
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    public func requestToggleRetweet(tweet: TWTRTweet) -> Observable<MBTweet> {
        if tweet.isRetweeted {
            return requestUnretweet(tweet)
        } else {
            return requestRetweet(tweet)
        }
    }

    public func requestRetweet(tweet: TWTRTweet) -> Observable<MBTweet> {
        return Observable.create { observer -> Disposable in
            let parameters = [ "id": tweet.tweetID ]
            _ = self.rxURLRequestWithMethod(.POST, url: "statuses/retweet", parameters: parameters, client: TwitterManager.getClient())
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

    public func requestUnretweet(tweet: TWTRTweet) -> Observable<MBTweet> {
        return Observable.create { observer -> Disposable in
            let parameters = [ "id": tweet.tweetID ]
            _ = self.rxURLRequestWithMethod(.POST, url: "statuses/unretweet", parameters: parameters, client: TwitterManager.getClient())
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

    public func requestToggleLikeTweet(tweet: TWTRTweet) -> Observable<MBTweet> {
        if tweet.isLiked {
            return requestUnlikeTweet(tweet)
        } else {
            return requestLikeTweet(tweet)
        }
    }

    public func requestLikeTweet(tweet: TWTRTweet) -> Observable<MBTweet> {
        return Observable.create { observer -> Disposable in
            let parameters = [
                "id": tweet.tweetID,
                "include_entities": "false"
            ]
            _ = self.rxURLRequestWithMethod(.POST, url: "favorites/create", parameters: parameters, client: TwitterManager.getClient())
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

    public func requestUnlikeTweet(tweet: TWTRTweet) -> Observable<MBTweet> {
        return Observable.create { (observer: AnyObserver<MBTweet>) -> Disposable in
            let parameters = [
                "id": tweet.tweetID,
                "include_entities": "false"
            ]
            _ = self.rxURLRequestWithMethod(.POST, url: "favorites/destroy", parameters: parameters, client:  TwitterManager.getClient())
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


    public func requestLists(ownerID: String) -> Observable<[MBTwitterList]> {
        return Observable.create { observer -> Disposable in
            let parameters = ["user_id": ownerID]
            _ = self.rxURLRequestWithMethod(.GET, url: "lists/list", parameters: parameters, client: TwitterManager.getClient())
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
        return Observable.create { observer -> Disposable in
            let parameters = [
                "list_id": userID,
                "count": String(count)
            ]
            _ = self.rxURLRequestWithMethod(.GET, url: "friends/list", parameters: parameters, client: TwitterManager.getClient())
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

    public func requestFollowerUsers(userID: String, count: Int = 20) -> Observable<[TwitterUser]> {
        return Observable.create { observer -> Disposable in
            let parameters = [
                "list_id": userID,
                "count": String(count)
            ]
            _ = self.rxURLRequestWithMethod(.GET, url: "followers/list", parameters: parameters, client: TwitterManager.getClient())
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



    public func requestListMembers(list: MBTwitterList, count: Int = MBTwitterList.memberNumActiveMaxLimit) -> Observable<[TwitterUser]> {
        return Observable.create { (observer) -> Disposable in
            let parameters = [
                "list_id": list.listID,
                "count": String(count)
            ]
            _ = self.rxURLRequestWithMethod(.GET, url: "lists/members", parameters: parameters, client: TwitterManager.getClient())
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


    public func rxLoadTimeline(count: Int, beforeID: String?, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { observer -> Disposable in
            var parameters = [
                "count": String(count),
                "include_entities": "false",
                "exclude_replies": "false"
            ]
            if let beforeID = beforeID {
                parameters["beforeID"] = beforeID
            }
            _ = self.rxURLRequestWithMethod(.GET, url: "statuses/home_timeline", parameters: parameters, client: client)
                .subscribe(
                    onNext: { data in
                        observer.onNext(data)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }



    public func rxURLRequestWithMethod(method: RequestMethod, url: String, parameters: [String : AnyObject], client: TWTRAPIClient)
        -> Observable<NSData> {
            return Observable.create { observer -> Disposable in
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
