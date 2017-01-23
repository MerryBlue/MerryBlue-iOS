import Foundation
import TwitterKit
import SwiftyJSON
import RxSwift

class TwitterManager {
    static let HOST = "https://api.twitter.com/1.1"
    static let listFilterMemberMaxNum = 50

    static func filterList(_ lists: [MBTwitterList]) -> [MBTwitterList] {
        return lists.filter { $0.memberCount <= listFilterMemberMaxNum }
    }

    static func sortUsersLastupdate(_ users: [TwitterUser]) -> [TwitterUser] {
        return users.sorted { return $0.compareLastTweetTo($1) }
    }

    static func sortUsersNewCount(_ users: [TwitterUser]) -> [TwitterUser] {
        return users.sorted { return $0.compareNewCountTo($1) }
    }

    static func sortUsersNewCountRev(_ users: [TwitterUser]) -> [TwitterUser] {
        return users.sorted { return $0.compareNewCountRevTo($1) }
    }

    static func sortTweetsLastupdate(_ tweets: [MBTweet]) -> [MBTweet] {
        return tweets.sorted { return $0.createdAt.compare($1.createdAt) == ComparisonResult.orderedDescending }
    }

    static func isLogin() -> Bool {
        return Twitter.sharedInstance().sessionStore.session() != nil
    }

    static func logoutUser() {
        guard let userID = getUserID() else {
            return
        }
        Twitter.sharedInstance().sessionStore.logOutUserID(userID)
    }

    static func getClient() -> TWTRAPIClient {
        return TWTRAPIClient(userID: getUserID())
    }

    static func getUserID() -> String! {
        guard let session = Twitter.sharedInstance().sessionStore.session() else {
            // print("Error: not authorized")
            return nil
        }
        return session.userID
    }

}
