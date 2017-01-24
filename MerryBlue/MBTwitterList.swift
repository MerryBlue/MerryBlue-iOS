import Foundation
import TwitterKit
import SwiftyJSON

public enum ListType: String {
    case Normal         = "normal"
    case RecentFollow   = "recentFollow"
    case RecentFollower = "recentFollower"
}

open class MBTwitterList: NSObject, NSCoding, MenuItemProtocol {
    var listID: String
    var name: String
    var fullName: String
    var slug: String
    var desc: String
    var memberCount: Int
    var imageUrl: String
    var listType: ListType
    var visible: Bool
    var isPrivate: Bool

    static let memberNumActiveMaxLimit = 100
    static let recentFollowUser = 20
    static let recentFollowerUser = 20

    init(jsonData: SwiftyJSON.JSON) {
        let user = TWTRUser(jsonDictionary: jsonData["user"].dictionaryObject)
        self.listID      = jsonData["id"].stringValue
        self.name        = jsonData["name"].stringValue
        self.fullName    = jsonData["full_name"].stringValue
        self.slug        = jsonData["slug"].stringValue
        self.desc        = jsonData["desc"].stringValue
        self.memberCount = jsonData["member_count"].intValue
        self.imageUrl    = (user?.profileImageURL)!
        self.visible     = true
        self.isPrivate   = jsonData["mode"] == "private"
        self.listType    = .Normal
    }

    init?(type: ListType) {
        self.fullName    = ""
        self.listID      = ""
        self.slug        = ""
        self.listType    = type
        self.visible     = true
        self.isPrivate   = false

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
        self.listID      = aDecoder.decodeObject(forKey: SerializedKey.ListID) as? String ?? "id error"
        self.name        = aDecoder.decodeObject(forKey: SerializedKey.Name) as? String ?? "name error"
        self.fullName    = aDecoder.decodeObject(forKey: SerializedKey.FullName) as? String ?? "fullName error"
        self.slug        = aDecoder.decodeObject(forKey: SerializedKey.Slug) as? String ?? "slug error"
        self.desc        = aDecoder.decodeObject(forKey: SerializedKey.Desc) as? String ?? "desc error"
        self.memberCount = aDecoder.decodeObject(forKey: SerializedKey.MemberCount) as? Int ?? 0
        self.imageUrl    = aDecoder.decodeObject(forKey: SerializedKey.ImageUrl) as? String ?? "image error"
        self.visible     = aDecoder.decodeObject(forKey: SerializedKey.Visible) as? Bool ?? true
        self.isPrivate   = aDecoder.decodeObject(forKey: SerializedKey.Private) as? Bool ?? true
        // old version patch
        if let typeID = aDecoder.decodeObject(forKey: SerializedKey.TypeID) as? Int, self.memberCount == 0 {
            self.listType = MBTwitterList.toType(typeID)
        } else {
            self.listType = ListType(rawValue: (aDecoder.decodeObject(forKey: SerializedKey.ListType) as? String)!) ?? ListType.Normal
        }
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.listID, forKey: SerializedKey.ListID)
        aCoder.encode(self.name, forKey: SerializedKey.Name)
        aCoder.encode(self.fullName, forKey: SerializedKey.FullName)
        aCoder.encode(self.slug, forKey: SerializedKey.Slug)
        aCoder.encode(self.desc, forKey: SerializedKey.Desc)
        aCoder.encode(self.memberCount, forKey: SerializedKey.MemberCount)
        aCoder.encode(self.imageUrl, forKey: SerializedKey.ImageUrl)
        aCoder.encode(self.listType.rawValue, forKey: SerializedKey.ListType)
        aCoder.encode(self.visible, forKey: SerializedKey.Visible)
        aCoder.encode(self.isPrivate, forKey: SerializedKey.Private)
    }

    static func toType(_ typeID: Int) -> ListType {
        return [ 0: ListType.Normal, 1: ListType.RecentFollow ][typeID]!
    }

    func isType(_ type: ListType) -> Bool {
        return self.listType == type
    }

    func isSpecialType() -> Bool {
        return self.listType != .Normal
    }

    func equalItem(_ list: MBTwitterList) -> Bool {
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
    static let FullName    = "fullName"
    static let Slug        = "slug"
    static let Desc        = "desc"
    static let MemberCount = "memberCount"
    static let ImageUrl    = "imageUrl"
    static let TypeID      = "typeID"
    static let ListType    = "listType"
    static let Visible     = "visilbe"
    static let Private     = "private"
}
