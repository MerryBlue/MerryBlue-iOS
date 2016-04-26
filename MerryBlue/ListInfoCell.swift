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
        self.contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCell(listInfo: MBTwitterList) {
        self.listNameLabel.text = listInfo.name
        self.memberNumLabel.text = String(listInfo.memberCount)
        switch listInfo.listType {
        case .Normal:
            self.iconImageView.sd_setImageWithURL(NSURL(string: listInfo.imageUrl), placeholderImage: AssetSertvice.sharedInstance.loadingImage)
        case .RecentFollow:
            self.iconImageView.image = AssetSertvice.sharedInstance.iconRecentFollow
            self.iconImageView.tintColor = MBColor.Main
        case .RecentFollower:
            self.iconImageView.image = AssetSertvice.sharedInstance.iconRecentFollower
            self.iconImageView.tintColor = MBColor.Main
        }

        if listInfo.isHomeTabEnable() {
            self.listNameLabel.textColor = UIColor.blackColor()
            self.memberNumLabel.textColor = UIColor.blackColor()
        } else {
            // 選択不可
            self.listNameLabel.textColor = MBColor.Sub
            self.memberNumLabel.textColor = MBColor.Sub
        }
    }

}
