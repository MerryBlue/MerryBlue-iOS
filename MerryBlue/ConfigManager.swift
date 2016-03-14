import Foundation

class ConfigManager {
    static private let configNameKey = "name"
    
    static func setName(text: String) {
        let defaults = self.getDefaults()
        defaults.setObject(text, forKey: configNameKey)
        defaults.synchronize()
    }
    static func getName() -> String {
        let defaults = self.getDefaults()
        return defaults.objectForKey(configNameKey) as! String
    }
    
    static func getDefaults() -> NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }
}