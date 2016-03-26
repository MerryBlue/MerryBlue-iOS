import Foundation
import TwitterKit
import SwiftyJSON

enum ListType {
    case Normal
    case RecentFollow
}

class TwitterList: NSObject, NSCoding, MenuItemProtocol {
    var listID: String
    var name: String
    var slug: String
    var desc: String
    var memberCount: Int
    var imageUrl: String
    var type = ListType.Normal
    var typeID: Int = 0

    static let memberNumActiveMaxLimit = 100
    static let recentFollowUser = 20

    init(jsonData: SwiftyJSON.JSON) {
        let user = TWTRUser(JSONDictionary: jsonData["user"].dictionaryObject)
        self.listID      = jsonData["id"].stringValue
        self.name        = jsonData["name"].stringValue
        self.slug        = jsonData["slug"].stringValue
        self.desc        = jsonData["desc"].stringValue
        self.memberCount = jsonData["member_count"].intValue
        self.imageUrl    = user.profileImageURL
    }

    init?(type: ListType) {
        self.listID      = ""
        self.slug        = ""
        self.type = type

        switch type {
        case .RecentFollow:
            self.name = "最近フォローしたユーザ"
            self.desc = "直近のフォロー\(TwitterList.recentFollowUser)人のメンバーです"
            self.memberCount = TwitterList.recentFollowUser
            self.imageUrl    = ""
            self.typeID = 1
        default:
            self.name = "---"
            self.desc = "---"
            self.memberCount = 0
            self.imageUrl    = ""
            self.typeID = 2
        }
    }

    required init?(coder aDecoder: NSCoder) {
        // NOTE: catch error
        self.listID      = aDecoder.decodeObjectForKey(SerializedKey.ListID) as? String ?? "id error"
        self.name        = aDecoder.decodeObjectForKey(SerializedKey.Name) as? String ?? "name error"
        self.slug        = aDecoder.decodeObjectForKey(SerializedKey.Slug) as? String ?? "slug error"
        self.desc        = aDecoder.decodeObjectForKey(SerializedKey.Desc) as? String ?? "desc error"
        self.memberCount = aDecoder.decodeObjectForKey(SerializedKey.MemberCount) as? Int ?? 0
        self.imageUrl    = aDecoder.decodeObjectForKey(SerializedKey.ImageUrl) as? String ?? "image error"
        self.typeID      = aDecoder.decodeObjectForKey(SerializedKey.TypeID) as? Int ?? 0
        self.type        = TwitterList.toType(self.typeID)
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.listID, forKey: SerializedKey.ListID)
        aCoder.encodeObject(self.name, forKey: SerializedKey.Name)
        aCoder.encodeObject(self.slug, forKey: SerializedKey.Slug)
        aCoder.encodeObject(self.desc, forKey: SerializedKey.Desc)
        aCoder.encodeObject(self.memberCount, forKey: SerializedKey.MemberCount)
        aCoder.encodeObject(self.imageUrl, forKey: SerializedKey.ImageUrl)
        aCoder.encodeObject(self.typeID, forKey: SerializedKey.TypeID)
    }

    static func toTypeID(type: ListType) -> Int {
        switch type {
        case .Normal: return 0
        case .RecentFollow: return 1
        }
    }

    static func toType(typeID: Int) -> ListType {
        return [ 0: ListType.Normal, 1: ListType.RecentFollow ][typeID]!
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
    static let TypeID      = "typeID"
}
