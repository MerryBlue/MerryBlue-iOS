import Foundation
import TwitterKit
import SwiftyJSON

class TwitterList: NSObject, NSCoding {
    var listID: String
    var name: String
    var slug: String
    var desc: String
    var memberCount: Int
    var imageUrl: String

    static let memberNumActiveMaxLimit = 100

    init(jsonData: SwiftyJSON.JSON) {
        let user = TWTRUser(JSONDictionary: jsonData["user"].dictionaryObject)
        self.listID      = jsonData["id"].stringValue
        self.name        = jsonData["name"].stringValue
        self.slug        = jsonData["slug"].stringValue
        self.desc        = jsonData["desc"].stringValue
        self.memberCount = jsonData["member_count"].intValue
        self.imageUrl    = user.profileImageURL
    }

    required init?(coder aDecoder: NSCoder) {
        // NOTE: catch error
        self.listID      = aDecoder.decodeObjectForKey(SerializedKey.ListID) as? String ?? "id error"
        self.name        = aDecoder.decodeObjectForKey(SerializedKey.Name) as? String ?? "name error"
        self.slug        = aDecoder.decodeObjectForKey(SerializedKey.Slug) as? String ?? "slug error"
        self.desc        = aDecoder.decodeObjectForKey(SerializedKey.Desc) as? String ?? "desc error"
        self.memberCount = aDecoder.decodeObjectForKey(SerializedKey.MemberCount) as? Int    ?? 0
        self.imageUrl    = aDecoder.decodeObjectForKey(SerializedKey.ImageUrl) as? String ?? "image error"
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.listID, forKey: SerializedKey.ListID)
        aCoder.encodeObject(self.name, forKey: SerializedKey.Name)
        aCoder.encodeObject(self.slug, forKey: SerializedKey.Slug)
        aCoder.encodeObject(self.desc, forKey: SerializedKey.Desc)
        aCoder.encodeObject(self.memberCount, forKey: SerializedKey.MemberCount)
        aCoder.encodeObject(self.imageUrl, forKey: SerializedKey.ImageUrl)
    }

    internal func enable() -> Bool {
        return self.memberCount < TwitterList.memberNumActiveMaxLimit
    }

    internal func disable() -> Bool {
        return !self.enable()
    }

}

struct SerializedKey {
    static let ListID      = "id"
    static let Name        = "name"
    static let Slug        = "slug"
    static let Desc        = "desc"
    static let MemberCount = "memberCount"
    static let ImageUrl    = "imageUrl"
}
