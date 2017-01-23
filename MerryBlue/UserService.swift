import Foundation

class UserService {

    static let sharedInstance = UserService()
    fileprivate let userDefaults = UserDefaults.standard

    func selectUser(_ userID: String) -> Int? {
        return self.userDefaults.object(forKey: forKeyUser(UserDefaultsKey.UserTweetCount, userID)) as? Int
    }

    func updateUser(_ userID: String, tweetCount: Int) {
        // let archive = NSKeyedArchiver.archivedDataWithRootObject(lists)
        self.userDefaults.set(tweetCount, forKey: forKeyUser(UserDefaultsKey.UserTweetCount, userID))
        self.userDefaults.synchronize()
    }

    // func selectLists() -> [MBTwitterList] {
    //     guard let unarchivedObject = self.userDefaults.objectForKey(forKeyUser(UserDefaultsKey.Lists)) as? NSData,
    //         let lists = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [MBTwitterList] else {
    //             return []
    //     }
    //
    //     return lists
    // }

    func forKeyUser(_ keys: String...) -> String {
        return ([TwitterManager.getUserID()] + keys).joined(separator: UserDefaultsKey.KeySeparator)
    }

}
