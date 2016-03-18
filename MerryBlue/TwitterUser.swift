import Foundation
import TwitterKit
import SwiftyJSON

class TwitterUser: TWTRUser {
    var lastStatus: TWTRTweet!
    var readedStatusId: String!
    
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
        self.readedStatusId = ConfigManager.getLastId(self.userID)
    }
    
    func hasNew() -> Bool {
        guard let stId = self.lastStatus.tweetID else {
            return false
        }
        guard let readedId = self.readedStatusId else {
            self.updateReadedStatusId()
            return false
        }
        return stId != readedId
    }
    
    func updateReadedStatusId() {
        ConfigManager.setLastId(self.userID, id: self.lastStatus.tweetID)
    }
    
}