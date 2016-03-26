class MBColor {
    internal static let Main = MBColor.fromHex(0x3e6ba2)
    internal static let Sub  = MBColor.fromHex(0xa0d9e2)
    internal static let Back = MBColor.fromHex(0xf8fcff)
    internal static let Dark = MBColor.fromHex(0x4d6196)

    static func fromHex(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}
