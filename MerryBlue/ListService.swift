import Foundation

class ListService {
    
    static let sharedInstance = ListService()
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func updateHomeList(list: TwitterList, id: Int) {
        updateHomeListID(list.id, id: id)
    }
    
    func selectHomeList(id: Int) -> TwitterList? {
        guard let listID = selectHomeListID(id) else {
            return nil
        }
        for list in selectLists() {
            if list.id == listID {
                return list
            }
        }
        return nil
    }
    
    
    func updateHomeListID(listID: String, id: Int) {
        self.userDefaults.setObject(listID, forKey: "\(UserDefaultsKey.HomeListId)::\(String(id))")
        self.userDefaults.synchronize()
    }
    
    func selectHomeListID(id: Int) -> String? {
        return self.userDefaults.objectForKey("\(UserDefaultsKey.HomeListId)::\(String(id))") as? String
    }
    
    
    func updateLists(lists: [TwitterList]) {
        let archive = NSKeyedArchiver.archivedDataWithRootObject(lists)
        self.userDefaults.setObject(archive, forKey: UserDefaultsKey.Lists)
        self.userDefaults.synchronize()
    }
    
    func selectLists() -> [TwitterList] {
        guard let unarchivedObject = self.userDefaults.objectForKey(UserDefaultsKey.Lists) as? NSData,
            let user = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [TwitterList] else {
                return []
        }
        
        return user
    }
}
