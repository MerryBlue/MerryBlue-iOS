import Foundation

class UserService {
    
    static let sharedInstance = UserService()
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func selectUser(userID: String) -> Int? {
        return self.userDefaults.objectForKey(forKeyUser(UserDefaultsKey.UserTweetCount, userID)) as? Int
    }
    
    func updateUser(userID: String, tweetCount: Int) {
        // let archive = NSKeyedArchiver.archivedDataWithRootObject(lists)
        self.userDefaults.setObject(tweetCount, forKey: forKeyUser(UserDefaultsKey.UserTweetCount, userID))
        self.userDefaults.synchronize()
    }
    
    // func selectLists() -> [TwitterList] {
    //     guard let unarchivedObject = self.userDefaults.objectForKey(forKeyUser(UserDefaultsKey.Lists)) as? NSData,
    //         let lists = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [TwitterList] else {
    //             return []
    //     }
    //     
    //     return lists
    // }
    
    func forKeyUser(keys: String...) -> String {
        return ([TwitterManager.getUserID()] + keys).joinWithSeparator(UserDefaultsKey.KeySeparator)
    }
}