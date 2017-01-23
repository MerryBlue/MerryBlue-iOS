import Foundation
import UIKit
import SDWebImage

class ListInfoCell: UITableViewCell {
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var memberNumLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCell(_ listInfo: MBTwitterList) {
        self.listNameLabel.text = listInfo.name
        self.memberNumLabel.text = String(listInfo.memberCount)
        switch listInfo.listType {
        case .Normal:
            self.iconImageView.sd_setImage(with: URL(string: listInfo.imageUrl), placeholderImage: AssetSertvice.sharedInstance.loadingImage)
        case .RecentFollow:
            self.iconImageView.image = AssetSertvice.sharedInstance.iconRecentFollow
            self.iconImageView.tintColor = MBColor.Main
        case .RecentFollower:
            self.iconImageView.image = AssetSertvice.sharedInstance.iconRecentFollower
            self.iconImageView.tintColor = MBColor.Main
        }
        self.memberNumLabel.textColor = UIColor.black
        self.listNameLabel.textColor = UIColor.black

        if !listInfo.isHomeTabEnable() {
            self.memberNumLabel.textColor = MBColor.Sub
        }
        if !listInfo.isTimelineTabEnable() {
            self.listNameLabel.textColor = MBColor.Sub
        }
    }

}
