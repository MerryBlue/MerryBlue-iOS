import Foundation
import TwitterKit
import RxSwift

public extension Twitter {

    /// Loads a Twitter User.
    ///
    /// - parameter userID:  ID of the user account to be fetched.
    /// - parameter client:  API client used to load the request.
    ///
    /// - returns: An Observable of the user.
    public func rxLoadUserShow(userID: String, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let httpMethod = "GET"
            let url = "https://api.twitter.com/1.1/users/show.json"
            let parameters = ["user_id": userID]

            _ = self.rxURLRequestWithMethod(httpMethod, url: url, parameters: parameters, client: client)
                .subscribe(
                    onNext: { data in
                        guard let data = data as? NSData else {
                            return
                        }
                        observer.onNext(data)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    /// Load the lists
    ///
    /// - parameter ownerID:  owner twitter userID.
    /// - parameter client:  API client used to load the request.
    ///
    /// - returns: The users data
    public func rxLoadLists(ownerID: String, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let httpMethod = "GET"
            let url = "https://api.twitter.com/1.1/lists/list.json"
            let parameters = ["user_id": ownerID]

            _ = self.rxURLRequestWithMethod(httpMethod, url: url, parameters: parameters, client: client)
                .subscribe(
                    onNext: { data in
                        guard let listsData = data as? NSData else {
                            return
                        }
                        observer.onNext(listsData)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    /// Load the friends.
    ///
    /// - parameter userID:  userID.
    /// - parameter client:  API client used to load the request.
    /// - parameter count:   Member count limit.
    ///
    /// - returns: The users data
    public func rxLoadFriendUsers(userID: String, client: TWTRAPIClient, count: Int = 40) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let httpMethod = "GET"
            let url = "https://api.twitter.com/1.1/friends/list.json"
            let parameters = [
                "list_id": userID,
                "count": String(count)
            ]

            _ = self.rxURLRequestWithMethod(httpMethod, url: url, parameters: parameters, client: client)
                .subscribe(
                    onNext: { data in
                        guard let usersData = data as? NSData else {
                            // observer.onError(TwitterError.Unknown)
                            return
                        }
                        observer.onNext(usersData)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    /// Load the follower.
    ///
    /// - parameter userID:  userID.
    /// - parameter client:  API client used to load the request.
    /// - parameter count:   Member count limit.
    ///
    /// - returns: The users data
    public func rxLoadFollowerUsers(userID: String, client: TWTRAPIClient, count: Int = 40) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let httpMethod = "GET"
            let url = "https://api.twitter.com/1.1/followers/list.json"
            let parameters = [
                "list_id": userID,
                "count": String(count)
            ]

            _ = self.rxURLRequestWithMethod(httpMethod, url: url, parameters: parameters, client: client)
                .subscribe(
                    onNext: { data in
                        guard let usersData = data as? NSData else {
                            // observer.onError(TwitterError.Unknown)
                            return
                        }
                        observer.onNext(usersData)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    /// Load the users in list.
    ///
    /// - parameter listID:  listID.
    /// - parameter client:  API client used to load the request.
    /// - parameter count:   Member count limit.
    ///
    /// - returns: The users data
    public func rxLoadListMembers(listID: String, client: TWTRAPIClient, count: Int = 50) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let httpMethod = "GET"
            let url = "https://api.twitter.com/1.1/lists/members.json"
            let parameters = [
                "list_id": listID,
                "count": String(count)
            ]
            _ = self.rxURLRequestWithMethod(httpMethod, url: url, parameters: parameters, client: client)
                .subscribe(
                    onNext: { data in
                        guard let usersData = data as? NSData else {
                            // observer.onError(TwitterError.Unknown)
                            return
                        }
                        observer.onNext(usersData)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    /// Load the user timeline.
    ///
    /// - parameter count:      The number of tweets to retrieve contained in the timeline.
    /// - parameter beforeID:
    /// - parameter client:     API client used to load the request.
    ///
    /// - returns: The timeline data.
    public func rxLoadTimeline(count: Int, beforeID: String?, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let httpMethod = "GET"
            let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
            var parameters = [
                "count": String(count),
                "include_entities": "false",
                "exclude_replies": "false"
            ]
            if let beforeID = beforeID {
                parameters["beforeID"] = beforeID
            }
            _ = self.rxURLRequestWithMethod(httpMethod, url: url, parameters: parameters, client: client)
                .subscribe(
                    onNext: { data in
                        guard let timeline = data as? NSData else {
                            // observer.onError(TwitterError.Unknown)
                            return
                        }
                        observer.onNext(timeline)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    /// Load the list timeline.
    ///
    /// - parameter listID:
    /// - parameter count:      The number of tweets to retrieve contained in the timeline.
    /// - parameter beforeID:
    /// - parameter client:     API client used to load the request.
    ///
    /// - returns: The timeline data.
    public func rxLoadListTimeline(listID: String, count: Int, beforeID: String?, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let httpMethod = "GET"
            let url = "https://api.twitter.com/1.1/lists/statuses.json"
            var parameters = [
                "list_id": listID,
                "count": String(count),
                "include_entities": "true",
                "include_rts": "true"
            ]
            if let beforeID = beforeID {
                parameters["beforeID"] = beforeID
            }
            _ = self.rxURLRequestWithMethod(httpMethod, url: url, parameters: parameters, client: client)
                .subscribe(
                    onNext: { data in
                        guard let timeline = data as? NSData else {
                            // observer.onError(TwitterError.Unknown)
                            return
                        }
                        observer.onNext(timeline)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    /// Load the user timeline.
    /// - parameter userID:       User id
    /// - parameter count:      The number of tweets to retrieve contained in the timeline.
    /// - parameter beforeID:
    /// - parameter client:     API client used to load the request.
    ///
    /// - returns: The timeline data.
    public func rxLoadUserTimeline(userID: String, count: Int, beforeID: String?, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let httpMethod = "GET"
            let url = "https://api.twitter.com/1.1/statuses/user_timeline.json"
            var parameters = [
                "user_id": userID,
                "count": String(count),
                "include_entities": "true",
                "exclude_replies": "false"
            ]
            if let beforeID = beforeID {
                parameters["max_id"] = beforeID
            }

            _ = self.rxURLRequestWithMethod(httpMethod, url: url, parameters: parameters, client: client)
                .subscribe(
                    onNext: { data in
                        guard let timeline = data as? NSData else {
                            // observer.onError(TwitterError.Unknown)
                            return
                        }
                        observer.onNext(timeline)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    /// Load conversations from tweet.
    /// - parameter tweetID:    Tweet id
    /// - parameter client:     API client used to load the request.
    ///
    /// - returns: The timeline data.
    public func rxLoadTweetConversions(tweetID: String, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let httpMethod = "GET"
            let url = "https://api.twitter.com/1.1/conversation/show.json"
            let parameters = [ "id": tweetID ]

            _ = self.rxURLRequestWithMethod(httpMethod, url: url, parameters: parameters, client: client)
                .subscribe(
                    onNext: { data in
                        guard let tweets = data as? NSData else {
                            // observer.onError(TwitterError.Unknown)
                            return
                        }
                        observer.onNext(tweets)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    /// Retweet Tweet
    /// - parameter tweetID:    Tweet id
    /// - parameter client:     API client used to load the request.
    ///
    /// - returns: The timeline data.
    public func rxLoadRetweet(tweetID: String, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let httpMethod = "POST"
            let url = "https://api.twitter.com/1.1/statuses/retweet.json"
            let parameters = [ "id": tweetID ]
            _ = self.rxURLRequestWithMethod(httpMethod, url: url, parameters: parameters, client: client)
                .subscribe(
                    onNext: { data in
                        guard let tweet = data as? NSData else {
                            // observer.onError(TwitterError.Unknown)
                            return
                        }
                        observer.onNext(tweet)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    /// Unretweet Tweet
    /// - parameter tweetID:    Tweet id
    /// - parameter client:     API client used to load the request.
    ///
    /// - returns: The timeline data.
    public func rxLoadUnretweet(tweetID: String, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let httpMethod = "POST"
            let url = "https://api.twitter.com/1.1/statuses/unretweet.json"
            let parameters = [ "id": tweetID ]
            _ = self.rxURLRequestWithMethod(httpMethod, url: url, parameters: parameters, client: client)
                .subscribe(
                    onNext: { data in
                        guard let tweet = data as? NSData else {
                            // observer.onError(TwitterError.Unknown)
                            return
                        }
                        observer.onNext(tweet)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }


    /// Like Tweet
    /// - parameter tweetID:    Tweet id
    /// - parameter client:     API client used to load the request.
    ///
    /// - returns: The timeline data.
    public func rxLoadLikeTweet(tweetID: String, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let httpMethod = "POST"
            let url = "https://api.twitter.com/1.1/favorites/create.json"
            let parameters = [
                "id": tweetID,
                "include_entities": "false"
            ]

            _ = self.rxURLRequestWithMethod(httpMethod, url: url, parameters: parameters, client: client)
                .subscribe(
                    onNext: { data in
                        guard let tweet = data as? NSData else {
                            // observer.onError(TwitterError.Unknown)
                            return
                        }
                        observer.onNext(tweet)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }


    /// unLike Tweet
    /// - parameter tweetID:    Tweet id
    /// - parameter client:     API client used to load the request.
    ///
    /// - returns: The timeline data.
    public func rxLoadUnlikeTweet(tweetID: String, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let httpMethod = "POST"
            let url = "https://api.twitter.com/1.1/favorites/destroy.json"
            let parameters = [
                "id": tweetID,
                "include_entities": "false"
            ]

            _ = self.rxURLRequestWithMethod(httpMethod, url: url, parameters: parameters, client: client)
                .subscribe(
                    onNext: { data in
                        guard let tweet = data as? NSData else {
                            // observer.onError(TwitterError.Unknown)
                            return
                        }
                        observer.onNext(tweet)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    }, onCompleted: nil, onDisposed: nil)
            return AnonymousDisposable { }
        }
    }

    /// Returns a signed URL request.
    ///
    /// - parameter method:     HTTP method of the request.
    /// - parameter url:        Full Twitter endpoint API URL.
    /// - parameter parameters: Request parameters.
    /// - parameter client:  API client used to load the request.
    ///
    /// - returns: The received object.
    public func rxURLRequestWithMethod(method: String, url: String, parameters: [String : AnyObject], client: TWTRAPIClient)
        -> Observable<AnyObject> {
            return Observable.create { (observer: AnyObserver<AnyObject>) -> Disposable in
                let request = client.URLRequestWithMethod(method, URL: url, parameters: parameters, error: nil)
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
