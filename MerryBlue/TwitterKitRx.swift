//
//  TwitterKit-Rx.swift
//  MerryBlue
//
//  Created by Hiroto Takahashi on 2016/03/19.
//  Copyright © 2016年 Hiroto Takahashi. All rights reserved.
//

import Foundation
import TwitterKit
// import RxSwift

/// Load the user.
///
/// - parameter count:   The number of tweets to retrieve contained in the timeline.
/// - parameter client:  API client used to load the request.
///
/// - returns: The timeline data.
public func rx_loadTimeline(count: Int, beforeID: String?, client: TWTRAPIClient) -> Observable<NSData> {
    return Observable.create { (observer: AnyObserver<NSData>) -> Disposable in
        let httpMethod = "GET"
        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        var parameters = ["count" : String(count), "include_entities" : "false", "exclude_replies" : "false"]
        if let beforeID = beforeID {
            parameters["beforeID"] = beforeID
        }
        
        _ = self.rx_URLRequestWithMethod(httpMethod, url: url, parameters: parameters, client: client)
            .subscribe(
                onNext: { data in
                    guard let timeline = data as? NSData else {
                        observer.onError(TwitterError.Unknown)
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