//
//  Rx-TwitterKit.swift
//  MerryBlue
//
//  Created by Hiroto Takahashi on 2016/03/20.
//  Copyright © 2016年 Hiroto Takahashi. All rights reserved.
//

import Foundation
import TwitterKit
import RxSwift

/// Loads a Twitter User.
///
/// - parameter userID:  ID of the user account to be fetched.
/// - parameter client:  API client used to load the request.
///
/// - returns: An Observable of the user.
public func rx_loadUserWithID(userID: String, client: TWTRAPIClient) -> Observable<TWTRUser> {
    return Observable.create { (observer: AnyObserver<TWTRUser>) -> Disposable in
        client.loadUserWithID(userID) { user, error in
            guard let user = user else {
                observer.onError(error!)
                return
            }
            observer.onNext(user)
            observer.onCompleted()
        }
        return AnonymousDisposable { }
    }
}