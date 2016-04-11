import Foundation

class ListService {

    static let sharedInstance = ListService()
    private let userDefaults = NSUserDefaults.standardUserDefaults()

    func updateHomeList(list: MBTwitterList) {
        let archive = NSKeyedArchiver.archivedDataWithRootObject(list)
        self.userDefaults.setObject(archive, forKey: forKeyUser(UserDefaultsKey.HomeList))
        self.userDefaults.synchronize()
    }

    func selectHomeList() -> MBTwitterList? {
        guard let unarchivedObject = self.userDefaults.objectForKey(forKeyUser(UserDefaultsKey.HomeList)) as? NSData,
            li = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? MBTwitterList else {
                return nil
        }
        return li
    }

    func updateLists(lists: [MBTwitterList]) {
        let archive = NSKeyedArchiver.archivedDataWithRootObject(lists)
        self.userDefaults.setObject(archive, forKey: forKeyUser(UserDefaultsKey.Lists))
        self.userDefaults.synchronize()
    }

    func selectLists() -> [MBTwitterList] {
        guard let unarchivedObject = self.userDefaults.objectForKey(forKeyUser(UserDefaultsKey.Lists)) as? NSData,
            li = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [MBTwitterList] else {
                return []
        }

        return li
    }

    /*
     * 順番を保持しながら更新したリストを返す
     */
    func fetchList(newLists: [MBTwitterList]) -> [MBTwitterList] {
        let oldLists = self.selectLists()
        var compLists = [MBTwitterList]()
        for oLi in oldLists {
            for nLi in newLists {
                if oLi.isSpecialType() {
                    compLists.append(oLi)
                    break
                } else if oLi.listID == nLi.listID {
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
    func adjustOptionalLists(lists: [MBTwitterList]) -> [MBTwitterList] {
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

    func forKeyUser(keys: String...) -> String {
        return ([TwitterManager.getUserID()] + keys).joinWithSeparator(UserDefaultsKey.KeySeparator)
    }

}
