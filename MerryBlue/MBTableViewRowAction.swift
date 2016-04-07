class MBTableViewRowAction: UITableViewRowAction {

    var image: UIImage?

    func _setButton(button: UIButton) {
        if let image = image, let titleLabel = button.titleLabel {
            let labelString = NSString(string: titleLabel.text!)
            let titleSize = labelString.sizeWithAttributes([NSFontAttributeName: titleLabel.font])

            button.tintColor = UIColor.whiteColor()
            button.setImage(image.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            button.imageEdgeInsets.right = -titleSize.width

        }
    }

    class func new(icon: UIImage, handler: (UITableViewRowAction, NSIndexPath) -> Void) -> MBTableViewRowAction {
        let rowAction = MBTableViewRowAction(style: .Normal, title: "      ", handler: handler)
        rowAction.image = icon
        rowAction.backgroundColor = MBColor.Main
        return rowAction
    }
}
