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
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCell(_ user: TwitterUser) {
        self.nameLabel.text = user.name
        self.screenNameLabel.text = "@\(user.screenName)"
        self.iconImageView.sd_setImage(with: URL(string: user.profileImageURL), placeholderImage: AssetSertvice.sharedInstance.loadingImage)
        guard let status = user.lastStatus else {
            self.tweetTextLabel.text = "ツイートが読み込めませんでした"
            self.timeElapsedLabel.text = "----/--/-- --:--:--"
            return
        }
        self.tweetTextLabel.text = status.arrangeText()
        self.timeElapsedLabel.text = status.createdAt.toFuzzy()

        if user.hasNew() {
            // self.layer.addBorder(UIRectEdge.Left, color: UIColor.greenColor(), thickness: 4)
            newCountLabel.isHidden = false
            newCountLabel.text = user.newCount() < 1000 ? String(user.newCount()) : "999"
        } else {
            newCountLabel.isHidden = true
        }
        self.backgroundColor = UIColor.white
    }

    func setInfoCell(_ message: String) {
        self.nameLabel.text = "情報セル"
        self.screenNameLabel.text = "( 'ω')"
        self.iconImageView.image = UIImage(named: "icon-replay-sq")
        self.iconImageView.tintColor = MBColor.Main
        self.tweetTextLabel.text = message
        self.timeElapsedLabel.text = Date().toFuzzy()
        self.backgroundColor = MBColor.LightSub

        newCountLabel.isHidden = true
        newCountLabel.text = "'_'"
    }

}
