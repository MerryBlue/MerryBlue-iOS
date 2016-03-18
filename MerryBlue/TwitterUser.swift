import Foundation
import TwitterKit
import SwiftyJSON

class TwitterUser: TWTRUser {
    var lastStatus: TWTRTweet!
    var readedStatusId: String!
    var preCount: Int!
    var tweetCount: Int!
    
    required override init!(JSONDictionary dictionary: [NSObject : AnyObject]!) {
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
        
        if let count = ConfigManager.getUserInfo(self.userID) {
            self.preCount = count
        } else {
            self.updateReadedCount()
        }
        
    }
    
    func hasNew() -> Bool {
        return self.tweetCount > self.preCount
    }
    
    func newCount() -> Int {
        return self.tweetCount - self.preCount
    }
    
    func updateReadedCount() {
        self.preCount = tweetCount
        ConfigManager.setUserInfo(self.userID, tweetCount: self.tweetCount)
    }
}