import Foundation
import TwitterKit
import SwiftyJSON

public enum ListType: String {
    case Normal         = "normal"
    case RecentFollow   = "recentFollow"
    case RecentFollower = "recentFollower"
}

public class MBTwitterList: NSObject, NSCoding, MenuItemProtocol {
    var listID: String
    var name: String
    var slug: String
    var desc: String
    var memberCount: Int
    var imageUrl: String
    var listType: ListType
    var visible: Bool

    static let memberNumActiveMaxLimit = 100
    static let recentFollowUser = 20
    static let recentFollowerUser = 20

    init(jsonData: SwiftyJSON.JSON) {
        let user = TWTRUser(JSONDictionary: jsonData["user"].dictionaryObject)
        self.listID      = jsonData["id"].stringValue
        self.name        = jsonData["name"].stringValue
        self.slug        = jsonData["slug"].stringValue
        self.desc        = jsonData["desc"].stringValue
        self.memberCount = jsonData["member_count"].intValue
        self.imageUrl    = user.profileImageURL
        self.visible     = true
        self.listType    = .Normal
    }

    init?(type: ListType) {
        self.listID      = ""
        self.slug        = ""
    self.listType = type
        self.visible = true

        switch type {
        case .RecentFollow:
            self.name = "直近フォロー"
            self.desc = "最近フォローした\(MBTwitterList.recentFollowUser)人のメンバーです"
            self.memberCount = MBTwitterList.recentFollowUser
            self.imageUrl    = ""
        case .RecentFollower:
            self.name = "直近フォロワー"
            self.desc = "最近あなたをフォローした\(MBTwitterList.recentFollowerUser)人のメンバーです"
            self.memberCount = MBTwitterList.recentFollowerUser
            self.imageUrl    = ""
        default:
            self.name = "---"
            self.desc = "---"
            self.memberCount = 0
            self.imageUrl    = ""
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        // NOTE: catch error
        self.listID      = aDecoder.decodeObjectForKey(SerializedKey.ListID) as? String ?? "id error"
        self.name        = aDecoder.decodeObjectForKey(SerializedKey.Name) as? String ?? "name error"
        self.slug        = aDecoder.decodeObjectForKey(SerializedKey.Slug) as? String ?? "slug error"
        self.desc        = aDecoder.decodeObjectForKey(SerializedKey.Desc) as? String ?? "desc error"
        self.memberCount = aDecoder.decodeObjectForKey(SerializedKey.MemberCount) as? Int ?? 0
        self.imageUrl    = aDecoder.decodeObjectForKey(SerializedKey.ImageUrl) as? String ?? "image error"
        self.visible     = aDecoder.decodeObjectForKey(SerializedKey.Visible) as? Bool ?? true
        // old version patch
        if let typeID = aDecoder.decodeObjectForKey(SerializedKey.TypeID) as? Int where self.memberCount == 0 {
            self.listType = MBTwitterList.toType(typeID)
        } else {
            self.listType = ListType(rawValue: (aDecoder.decodeObjectForKey(SerializedKey.ListType) as? String)!) ?? ListType.Normal
        }
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.listID, forKey: SerializedKey.ListID)
        aCoder.encodeObject(self.name, forKey: SerializedKey.Name)
        aCoder.encodeObject(self.slug, forKey: SerializedKey.Slug)
        aCoder.encodeObject(self.desc, forKey: SerializedKey.Desc)
        aCoder.encodeObject(self.memberCount, forKey: SerializedKey.MemberCount)
        aCoder.encodeObject(self.imageUrl, forKey: SerializedKey.ImageUrl)
        aCoder.encodeObject(self.listType.rawValue, forKey: SerializedKey.ListType)
        aCoder.encodeObject(self.visible, forKey: SerializedKey.Visible)
    }

    static func toType(typeID: Int) -> ListType {
        return [ 0: ListType.Normal, 1: ListType.RecentFollow ][typeID]!
    }

    func isType(type: ListType) -> Bool {
        return self.listType == type
    }

    func isSpecialType() -> Bool {
        return self.listType != .Normal
    }

    func equalItem(list: MBTwitterList) -> Bool {
        return self.listType == list.listType && self.listID == list.listID
    }

    func isHomeTabEnable() -> Bool {
        return self.memberCount < MBTwitterList.memberNumActiveMaxLimit
    }

    func isTimelineTabEnable() -> Bool {
        return [ListType.Normal].contains(self.listType)
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
    static let ListType    = "listType"
    static let Visible     = "visilbe"
}
