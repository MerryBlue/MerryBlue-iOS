import Foundation

class ListService {

    static let sharedInstance = ListService()
    private let userDefaults = NSUserDefaults.standardUserDefaults()

    func updateHomeList(list: TwitterList) {
        updateHomeListID(list.listID)
    }

    func selectHomeList() -> TwitterList? {
        guard let listID = selectHomeListID() else {
            return nil
        }
        for list in selectLists() {
            if list.listID == listID {
                return list
            }
        }
        return nil
    }

    func updateHomeListID(listID: String) {
        self.userDefaults.setObject(listID, forKey: forKeyUser(UserDefaultsKey.HomeListId))
        self.userDefaults.synchronize()
    }

    func selectHomeListID() -> String? {
        return self.userDefaults.objectForKey(forKeyUser(UserDefaultsKey.HomeListId)) as? String
    }

    func updateLists(lists: [TwitterList]) {
        let archive = NSKeyedArchiver.archivedDataWithRootObject(lists)
        self.userDefaults.setObject(archive, forKey: forKeyUser(UserDefaultsKey.Lists))
        self.userDefaults.synchronize()
    }

    func selectLists() -> [TwitterList] {
        guard let unarchivedObject = self.userDefaults.objectForKey(forKeyUser(UserDefaultsKey.Lists)) as? NSData,
            li = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [TwitterList] else {
                return []
        }

        return li
    }

    /*
     * 順番を保持しながら更新したリストを返す
     */
    func fetchList(newLists: [TwitterList]) -> [TwitterList] {
        let oldLists = self.selectLists()
        var compLists = [TwitterList]()
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

    // RecentFollow type の Twitter リストが必ず一つ含まれるリストにして返す
    func adjustOptionalLists(lists: [TwitterList]) -> [TwitterList] {
        let recentListCount = lists.reduce(0) { (sum, list) -> Int in
            sum + (list.isRecentFollowType() ? 1 : 0)
        }

        if recentListCount == 1 {
            return lists
        }
        return (lists.filter { (list) -> Bool in !list.isRecentFollowType() }) + [TwitterList](arrayLiteral: TwitterList(type: ListType.RecentFollow)!)
    }

    func forKeyUser(keys: String...) -> String {
        return ([TwitterManager.getUserID()] + keys).joinWithSeparator(UserDefaultsKey.KeySeparator)
    }

}
