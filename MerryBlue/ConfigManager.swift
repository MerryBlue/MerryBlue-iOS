import Foundation

class ConfigManager {
    static private let configNameKey = "name"
    static private let userCountStatusKeyPrefix = "lscount-"
    
    static func setName(text: String) {
        updateData(configNameKey, value: text)
    }
    static func getName() -> String? {
        return selectData(configNameKey) as? String
    }
   
    
    static func setUserInfo(userID: String, tweetCount: Int) {
        updateData(userCountStatusKeyPrefix + userID, value: tweetCount)
    }
    
    static func getUserInfo(userID: String) -> Int? {
        return selectData(userCountStatusKeyPrefix + userID) as? Int
    }
    
    
    
    /* */
    static func selectData(key: String) -> AnyObject? {
        let defaults = self.getDefaults()
        return defaults.objectForKey(key)
    }
    
    static func updateData(key: String, value: AnyObject) {
        let defaults = self.getDefaults()
        defaults.setObject(value, forKey: key)
        defaults.synchronize()
    }
    
    static func getDefaults() -> NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }
}