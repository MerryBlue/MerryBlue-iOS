class ConfigService {

    static let sharedInstance = ConfigService()
    private let userDefaults = NSUserDefaults.standardUserDefaults()

    func selectOrderType(userID: String) -> Int! {
        return self.userDefaults.objectForKey(forKeyUser(UserDefaultsKey.OrderType, userID)) as? Int
    }

    func updateOrderType(userID: String, type: Int) {
        self.userDefaults.setObject(type, forKey: forKeyUser(UserDefaultsKey.OrderType, userID))
        self.userDefaults.synchronize()
    }

    func forKeyUser(keys: String...) -> String {
        return ([TwitterManager.getUserID()] + keys).joinWithSeparator(UserDefaultsKey.KeySeparator)
    }

}
