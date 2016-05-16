class ConfigService {

    static let sharedInstance = ConfigService()
    private let userDefaults = NSUserDefaults.standardUserDefaults()

    func selectOrderType(userID: String) -> HomeViewOrderType {
        guard let typeRaw = self.userDefaults.objectForKey(forKeyUser(UserDefaultsKey.OrderType, userID)) as? Int else {
            return HomeViewOrderType.ReadCountOrder
        }
        return HomeViewOrderType(rawValue: typeRaw)!
    }

    func selectImageViewModeType(userID: String) -> ImageViewType {
        guard let typeRaw = self.userDefaults.objectForKey(forKeyUser(UserDefaultsKey.ImageViewModeType, userID)) as? Int else {
            return ImageViewType.ExcludeRT
        }
        return ImageViewType(rawValue: typeRaw)!
    }

    func selectInfoModeType(userID: String) -> Bool {
        guard let typeRaw = self.userDefaults.objectForKey(forKeyUser(UserDefaultsKey.ImageInfoModeType, userID)) as? Bool else {
            return false
        }
        return typeRaw
    }

    func updateOrderType(userID: String, type: HomeViewOrderType) {
        self.userDefaults.setObject(type.rawValue, forKey: forKeyUser(UserDefaultsKey.OrderType, userID))
        self.userDefaults.synchronize()
    }

    func updateImageViewModeType(userID: String, type: ImageViewType) {
        self.userDefaults.setObject(type.rawValue, forKey: forKeyUser(UserDefaultsKey.ImageViewModeType, userID))
        self.userDefaults.synchronize()
    }

    func updateImageInfoModeType(userID: String, type: Bool) {
        self.userDefaults.setObject(type, forKey: forKeyUser(UserDefaultsKey.ImageInfoModeType, userID))
        self.userDefaults.synchronize()
    }

    func forKeyUser(keys: String...) -> String {
        return ([TwitterManager.getUserID()] + keys).joinWithSeparator(UserDefaultsKey.KeySeparator)
    }

}
