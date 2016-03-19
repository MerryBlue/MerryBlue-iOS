import Foundation
import TwitterKit
import SwiftyJSON

class TwitterList: NSObject, NSCoding {
    var id:           String
    var name:         String
    var slug:         String
    var desc:         String
    var member_count: Int
    var imageUrl:     String
    
    static let MEMBER_NUM_ACTIVE_MAX_LIMIT = 50
    
    init(jsonData: SwiftyJSON.JSON) {
        let user = TWTRUser(JSONDictionary: jsonData["user"].dictionaryObject)
        self.id           = jsonData["id"].stringValue
        self.name         = jsonData["name"].stringValue
        self.slug         = jsonData["slug"].stringValue
        self.desc         = jsonData["desc"].stringValue
        self.member_count = jsonData["member_count"].intValue
        self.imageUrl     = user.profileImageURL
    }

    required init?(coder aDecoder: NSCoder) {
        self.id           = aDecoder.decodeObjectForKey(SerializedKey.Id         ) as? String ?? "id error"
        self.name         = aDecoder.decodeObjectForKey(SerializedKey.Name       ) as? String ?? "name error"
        self.slug         = aDecoder.decodeObjectForKey(SerializedKey.Slug       ) as? String ?? "slug error"
        self.desc         = aDecoder.decodeObjectForKey(SerializedKey.Desc       ) as? String ?? "desc error"
        self.member_count = aDecoder.decodeObjectForKey(SerializedKey.MemberCount) as? Int    ?? 0
        self.imageUrl     = aDecoder.decodeObjectForKey(SerializedKey.ImageUrl   ) as? String ?? "image error"
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.id,           forKey: SerializedKey.Id)
        aCoder.encodeObject(self.name,         forKey: SerializedKey.Name)
        aCoder.encodeObject(self.slug,         forKey: SerializedKey.Slug)
        aCoder.encodeObject(self.desc       ,  forKey: SerializedKey.Desc       )
        aCoder.encodeObject(self.member_count, forKey: SerializedKey.MemberCount)
        aCoder.encodeObject(self.imageUrl,     forKey: SerializedKey.ImageUrl)
    }
    
    internal func enable() -> Bool {
        return self.member_count < TwitterList.MEMBER_NUM_ACTIVE_MAX_LIMIT
    }
    
    internal func disable() -> Bool {
        return !self.enable()
    }
}

struct SerializedKey {
    static let Id          = "id"
    static let Name        = "name"
    static let Slug        = "slug"
    static let Desc        = "desc"
    static let MemberCount = "memberCount"
    static let ImageUrl    = "imageUrl"
}
