import Foundation
import TwitterKit
import SwiftyJSON

class TwitterList {
    var id: String
    var name: String
    var slug: String
    var description: String
    var member_count: Int
    var user: TWTRUser
    
    static let MEMBER_NUM_ACTIVE_MAX_LIMIT = 50
    
    init(jsonData: SwiftyJSON.JSON) {
        self.id = jsonData["id"].stringValue
        self.name = jsonData["name"].stringValue
        self.slug = jsonData["slug"].stringValue
        self.description = jsonData["description"].stringValue
        self.member_count = jsonData["member_count"].intValue
        self.user = TWTRUser(JSONDictionary: jsonData["user"].dictionaryObject)
    }
    
    internal func enable() -> Bool {
        return self.member_count < TwitterList.MEMBER_NUM_ACTIVE_MAX_LIMIT
    }
    
    internal func disable() -> Bool {
        return !self.enable()
    }
    
}