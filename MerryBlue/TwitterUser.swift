import UIKit
import Foundation
import TwitterKit
import SwiftyJSON

open class TwitterUser: TWTRUser {
    var lastStatus: MBTweet!
    var readedStatusId: String!
    var preCount: Int!
    var tweetCount: Int!
    var isFollowing = false
    var profileBackgroundImageURL: String!
    var profileBannerImageURL: String!
    var color: UIColor!

    override init() {
        super.init()
    }

    required override public init!(jsonDictionary dictionary: [AnyHashable: Any]!) {
        super.init(jsonDictionary: dictionary)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init?(json: SwiftyJSON.JSON) {
        super.init(jsonDictionary: json.dictionaryObject)
        if json["status"] != nil {
            self.lastStatus = MBTweet(json: json["status"])
        } else {
            self.lastStatus = nil
        }
        self.tweetCount = json["statuses_count"].intValue
        self.isFollowing = json["following"].boolValue
        self.profileBackgroundImageURL = json["profile_background_image_url_https"].stringValue
        self.profileBannerImageURL = json["profile_banner_url"].stringValue
        let colStr = json["profile_sidebar_fill_color"].stringValue
        if colStr != "000000" {
            self.color = UIColor.hex(hexStr: colStr)
        } else {
            self.color = MBColor.Main
        }

        if let count = UserService.sharedInstance.selectUser(self.userID), !isSecret() {
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

    func compareNewCountTo(_ user: TwitterUser) -> Bool {
        let c = self.newCount() - user.newCount()
        if c != 0 {
            return c > 0
        }
        return self.compareLastTweetTo(user)
    }

    // NewCount が少ない順 ただし 0 は最後
    func compareNewCountRevTo(_ user: TwitterUser) -> Bool {
        // 小さい順
        if self.newCount() == 0 && user.newCount() > 0 {
            return false
        } else if self.newCount() > 0 && user.newCount() == 0 {
            return true
        }
        let c = self.newCount() - user.newCount()
        if c != 0 {
            return c < 0
        }
        return self.compareLastTweetTo(user)
    }

    func compareLastTweetTo(_ user: TwitterUser) -> Bool {
        guard let s1 = self.lastStatus else {
            return false
        }
        guard let s2 = user.lastStatus else {
            return true
        }
        return s1.createdAt.compare(s2.createdAt) == ComparisonResult.orderedDescending
    }

}
