import Foundation
import UIKit

class MBTableViewRowAction: UITableViewRowAction {

    var image: UIImage?

    func _setButton(_ button: UIButton) {
        if let image = image, let titleLabel = button.titleLabel {
            let labelString = titleLabel.text!
            let titleSize = labelString.size(attributes: [NSFontAttributeName: titleLabel.font])

            button.tintColor = UIColor.white
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageEdgeInsets.right = -titleSize.width

        }
    }

    class func new(_ icon: UIImage, handler: @escaping (UITableViewRowAction, NSIndexPath) -> Void) -> MBTableViewRowAction {
        let rowAction = MBTableViewRowAction(style: .normal, title: "      ") {action, index in
            handler(action, index as NSIndexPath)
        }
        rowAction.image = icon
        rowAction.backgroundColor = MBColor.Main
        return rowAction
    }
}
