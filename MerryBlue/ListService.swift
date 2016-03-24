import Foundation

class ListService {
    
    static let sharedInstance = ListService()
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func updateHomeList(list: TwitterList) {
        updateHomeListID(list.id)
    }
    
    func selectHomeList() -> TwitterList? {
        guard let listID = selectHomeListID() else {
            return nil
        }
        for list in selectLists() {
            if list.id == listID {
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
            let lists = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [TwitterList] else {
                return []
        }
        
        return lists
    }
    
    func forKeyUser(keys: String...) -> String {
        return ([TwitterManager.getUserID()] + keys).joinWithSeparator(UserDefaultsKey.KeySeparator)
    }
}
