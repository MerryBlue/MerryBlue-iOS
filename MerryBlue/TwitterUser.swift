import Foundation
import TwitterKit
import SwiftyJSON

class TwitterUser: TWTRUser {
    var lastStatus: TWTRTweet!
    
    required override init!(JSONDictionary dictionary: [NSObject : AnyObject]!) {
        super.init(JSONDictionary: dictionary)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(json: SwiftyJSON.JSON) {
        super.init(JSONDictionary: json.dictionaryObject)
        self.lastStatus = TWTRTweet(JSONDictionary: json["status"].dictionaryObject)
        // self.profileImageURL = json["profile_image_url"].stringValue
    }
}