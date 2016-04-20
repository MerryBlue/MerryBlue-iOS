class ConfigService {

    static let sharedInstance = ConfigService()
    private let userDefaults = NSUserDefaults.standardUserDefaults()

    func selectOrderType(userID: String) -> HomeViewOrderType {
        guard let typeRaw = self.userDefaults.objectForKey(forKeyUser(UserDefaultsKey.OrderType, userID)) as? Int else {
            return HomeViewOrderType.ReadCountOrder
        }
        return HomeViewOrderType(rawValue: typeRaw)!
    }

    func updateOrderType(userID: String, type: HomeViewOrderType) {
        self.userDefaults.setObject(type.rawValue, forKey: forKeyUser(UserDefaultsKey.OrderType, userID))
        self.userDefaults.synchronize()
    }

    func forKeyUser(keys: String...) -> String {
        return ([TwitterManager.getUserID()] + keys).joinWithSeparator(UserDefaultsKey.KeySeparator)
    }

}
