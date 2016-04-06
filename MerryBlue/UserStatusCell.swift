import Foundation
import UIKit
import SDWebImage

class UserStatusCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var newCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCell(user: TwitterUser) {
        self.nameLabel.text = user.name
        self.screenNameLabel.text = "@\(user.screenName)"

        self.iconImageView.sd_setImageWithURL(NSURL(string: user.profileImageURL), placeholderImage: AssetSertvice.sharedInstance.loadingImage)

        guard let status = user.lastStatus else {
            self.tweetTextLabel.text = "ツイートが読み込めませんでした"
            self.timeElapsedLabel.text = "----/--/-- --:--:--"
            return
        }
        self.tweetTextLabel.text = status.text

        self.timeElapsedLabel.text = status.createdAt.toFuzzy()

        if user.hasNew() {
            // self.layer.addBorder(UIRectEdge.Left, color: UIColor.greenColor(), thickness: 4)
            newCountLabel.hidden = false
            newCountLabel.text = user.newCount() <= 100 ? String(user.newCount()) : "︙"
        } else {
            newCountLabel.hidden = true
        }
    }

}
