import Foundation
import TwitterKit
import SwiftyJSON

class TwitterUser: TWTRUser {
    var lastStatus: TWTRTweet!
    var readedStatusId: String!
    var preCount: Int!
    var tweetCount: Int!
    var isFollowing = false
    var profileBackgroundImageURL: String!

    required override init!(JSONDictionary dictionary: [NSObject: AnyObject]!) {
        super.init(JSONDictionary: dictionary)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init?(json: SwiftyJSON.JSON) {
        super.init(JSONDictionary: json.dictionaryObject)
        if json["status"] != nil {
            self.lastStatus = TWTRTweet(JSONDictionary: json["status"].dictionaryObject)
        } else {
            self.lastStatus = nil
        }
        self.tweetCount = json["statuses_count"].intValue
        self.isFollowing = json["following"].boolValue
        self.profileBackgroundImageURL = json["profile_background_image_url_https"].stringValue

        if let count = UserService.sharedInstance.selectUser(self.userID) where !isSecret() {
            // ログあり かつ 相手のツイートが見れる場合
            self.preCount = count
            self.tweetCount = Int(max(self.tweetCount, self.preCount))
        } else {
            self.updateReadedCount()
        }

    }

    func isSecret() -> Bool {
        return self.isProtected && !self.isFollowing
    }

    func hasNew() -> Bool {
        return self.tweetCount > self.preCount
    }

    func newCount() -> Int {
        return max(0, self.tweetCount - self.preCount)
    }

    func updateReadedCount() {
        self.preCount = tweetCount
        UserService.sharedInstance.updateUser(self.userID, tweetCount: self.tweetCount)
    }

    func compareNewCountTo(user: TwitterUser) -> Bool {
        let c = self.newCount() - user.newCount()
        if c != 0 {
            return c > 0
        }
        return self.compareLastTweetTo(user)
    }

    func compareLastTweetTo(user: TwitterUser) -> Bool {
        guard let s1 = self.lastStatus else {
            return false
        }
        guard let s2 = user.lastStatus else {
            return true
        }
        return s1.createdAt.compare(s2.createdAt) == NSComparisonResult.OrderedDescending
    }

}
