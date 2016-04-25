import Foundation
import TwitterKit
import RxSwift

public extension Twitter {

    enum RequestMethod: String {
        case GET = "GET"
        case POST = "POST"
    }
    public func APIHost() -> String {
        return "https://api.twitter.com/1.1/"
    }

    public func rxLoadUserShow(userID: String, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let parameters = ["user_id": userID]
            _ = self.rxURLRequestWithMethod(.GET, url: "users/show", parameters: parameters, client: client)
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

    public func rxLoadLists(ownerID: String, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let parameters = ["user_id": ownerID]
            _ = self.rxURLRequestWithMethod(.GET, url: "lists/list", parameters: parameters, client: client)
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

    public func rxLoadFriendUsers(userID: String, client: TWTRAPIClient, count: Int = 40) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let parameters = [
                "list_id": userID,
                "count": String(count)
            ]
            _ = self.rxURLRequestWithMethod(.GET, url: "friends/list", parameters: parameters, client: client)
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

    public func rxLoadFollowerUsers(userID: String, client: TWTRAPIClient, count: Int = 40) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let parameters = [
                "list_id": userID,
                "count": String(count)
            ]
            _ = self.rxURLRequestWithMethod(.GET, url: "followers/list", parameters: parameters, client: client)
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

    public func rxLoadListMembers(listID: String, client: TWTRAPIClient, count: Int = 50) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let parameters = [
                "list_id": listID,
                "count": String(count)
            ]
            _ = self.rxURLRequestWithMethod(.GET, url: "lists/members", parameters: parameters, client: client)
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

    public func rxLoadTimeline(count: Int, beforeID: String?, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
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

    public func rxLoadListTimeline(listID: String, count: Int, beforeID: String?, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            var parameters = [
                "list_id": listID,
                "count": String(count),
                "include_entities": "true",
                "include_rts": "true"
            ]
            if let beforeID = beforeID {
                parameters["beforeID"] = beforeID
            }
            _ = self.rxURLRequestWithMethod(.GET, url: "lists/statuses", parameters: parameters, client: client)
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

    public func rxLoadUserTimeline(userID: String, count: Int, beforeID: String?, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            var parameters = [
                "user_id": userID,
                "count": String(count),
                "include_entities": "true",
                "exclude_replies": "false"
            ]
            if let beforeID = beforeID {
                parameters["max_id"] = beforeID
            }

            _ = self.rxURLRequestWithMethod(.GET, url: "statuses/user_timeline", parameters: parameters, client: client)
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

    public func rxLoadTweetConversions(tweetID: String, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let parameters = [ "id": tweetID ]
            _ = self.rxURLRequestWithMethod(.GET, url: "conversation/show", parameters: parameters, client: client)
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

    public func rxLoadRetweet(tweetID: String, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let parameters = [ "id": tweetID ]
            _ = self.rxURLRequestWithMethod(.POST, url: "statuses/retweet", parameters: parameters, client: client)
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

    public func rxLoadUnretweet(tweetID: String, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let parameters = [ "id": tweetID ]
            _ = self.rxURLRequestWithMethod(.POST, url: "statuses/unretweet", parameters: parameters, client: client)
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


    public func rxLoadLikeTweet(tweetID: String, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let parameters = [
                "id": tweetID,
                "include_entities": "false"
            ]
            _ = self.rxURLRequestWithMethod(.POST, url: "favorites/create", parameters: parameters, client: client)
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


    public func rxLoadUnlikeTweet(tweetID: String, client: TWTRAPIClient) -> Observable<NSData> {
        return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
            let parameters = [
                "id": tweetID,
                "include_entities": "false"
            ]
            _ = self.rxURLRequestWithMethod(.POST, url: "favorites/destroy", parameters: parameters, client: client)
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
            return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
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
