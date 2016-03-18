import Foundation

class ListService {
    
    static let sharedInstance = ListService()
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
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
