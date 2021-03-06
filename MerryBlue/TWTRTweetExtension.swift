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
        return self.isRetweet ? self.retweeted : self
    }

    func isOwnTweet() -> Bool {
        return self.sourceTweet().author.userID == TwitterManager.getUserID()
    }

    // 絵文字に置き換え
    func arrangeText() -> String {
        var text = self.prettyText()
        if text.characters.count < 5 {
            return text
        }
        if self.isRetweet {
            text = "🔁" + text
        }
        if (text as NSString).substring(to: 1) == "@" {
            text = "💬" + text
        }
        return text
    }

    // URL などを取り除いたテキスト
    func prettyText() -> String {
        // replace url
        let regex: NSRegularExpression
        do {
            let pattern = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"
            let replace = "🔗[URL]"
            regex = try NSRegularExpression(pattern: pattern, options: [])
            return regex.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: text.characters.count), withTemplate: replace)
        } catch _ {
            print("regex error")
        }
        return self.text
    }

    func miniDisplayLikeCount() -> String {
        if self.likeCount > 99 {
            return "99+"
        }
        return String(self.likeCount)
    }

    func miniDisplayRetweetCount() -> String {
        if self.retweetCount > 99 {
            return "99+"
        }
        return String(self.retweetCount)
    }

}
