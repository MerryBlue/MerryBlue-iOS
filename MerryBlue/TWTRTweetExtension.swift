//
//  TWTRTweetExtension.swift
//  MerryBlue
//
//  Created by Hiroto Takahashi on 2016/04/23.
//  Copyright © 2016年 Hiroto Takahashi. All rights reserved.
//

import TwitterKit

extension TWTRTweet {
    func sourceTweet() -> TWTRTweet {
        return self.isRetweet ? self.retweetedTweet : self
    }

    func isOwnTweet() -> Bool {
        return self.sourceTweet().author.userID == TwitterManager.getUserID()
    }
}
