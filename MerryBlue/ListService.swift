import Foundation

class ListService {

    static let sharedInstance = ListService()
    fileprivate let userDefaults = UserDefaults.standard
    var delegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!

    func updateHomeList(_ list: MBTwitterList) {
        delegate.homeList = list
        let archive = NSKeyedArchiver.archivedData(withRootObject: list)
        self.userDefaults.set(archive, forKey: forKeyUser(UserDefaultsKey.HomeList))
        self.userDefaults.synchronize()
    }

    func selectHomeList() -> MBTwitterList? {
        if let homeList = delegate.homeList {
            return homeList
        }
        guard let unarchivedObject = self.userDefaults.object(forKey: forKeyUser(UserDefaultsKey.HomeList)) as? Data,
            let li = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? MBTwitterList else {
                return nil
        }
        return li
    }

    func updateLists(_ lists: [MBTwitterList]) {
        let archive = NSKeyedArchiver.archivedData(withRootObject: lists)
        self.userDefaults.set(archive, forKey: forKeyUser(UserDefaultsKey.Lists))
        self.userDefaults.synchronize()
    }

    func selectLists() -> [MBTwitterList] {
        guard let unarchivedObject = self.userDefaults.object(forKey: forKeyUser(UserDefaultsKey.Lists)) as? Data,
            let li = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? [MBTwitterList] else {
                return []
        }

        return li
    }

    /*
     * 順番を保持しながら更新したリストを返す
     */
    func fetchList(_ newLists: [MBTwitterList]) -> [MBTwitterList] {
        let oldLists = self.selectLists()
        var compLists = [MBTwitterList]()
        for oLi in oldLists {
            if oLi.isSpecialType() {
                compLists.append(oLi)
                continue
            }
            for nLi in newLists {
                if oLi.listID == nLi.listID {
                    compLists.append(nLi)
                    break
                }
            }
        }
        for nLi in newLists {
            if !compLists.contains(nLi) {
                compLists.append(nLi)
            }
        }
        return compLists
    }

    // special type の Twitter リストが必ず一つずつ含まれるリストにして返す
    func adjustOptionalLists(_ lists: [MBTwitterList]) -> [MBTwitterList] {
        var resLists = lists
        let recentFollowTypeCont = lists.reduce(0) { (sum, list) -> Int in sum + (list.isType(ListType.RecentFollow) ? 1 : 0) }
        if recentFollowTypeCont != 1 {
            resLists = (resLists.filter { (list) -> Bool in !list.isType(ListType.RecentFollow) }) + [MBTwitterList](arrayLiteral: MBTwitterList(type: ListType.RecentFollow)!)
        }
        let recentFollowerTypeCont = lists.reduce(0) { (sum, list) -> Int in sum + (list.isType(ListType.RecentFollower) ? 1 : 0) }
        if recentFollowerTypeCont != 1 {
            resLists = (resLists.filter { (list) -> Bool in !list.isType(ListType.RecentFollower) }) + [MBTwitterList](arrayLiteral: MBTwitterList(type: ListType.RecentFollower)!)
        }
        return resLists
    }

    func forKeyUser(_ keys: String...) -> String {
        return ([TwitterManager.getUserID()] + keys).joined(separator: UserDefaultsKey.KeySeparator)
    }

}
