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

    // 絵文字に置き換え
    func arrangeText() -> String {
        var text = self.prettyText()
        if text.characters.count < 5 {
            return text
        }
        // is mention
        if (text as NSString).substringToIndex(1) == "@" {
            text = "🔁" + text
        }
        // is retweet
        if (text as NSString).substringToIndex(5) == "RT: @" {
            text = text.stringByReplacingOccurrencesOfString("RT:", withString: "💬", options: [])
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
            return regex.stringByReplacingMatchesInString(text, options: [], range: NSRange(location: 0, length: text.characters.count), withTemplate: replace)
        } catch _ {
            print("regex error")
        }
        return self.text
    }
}
