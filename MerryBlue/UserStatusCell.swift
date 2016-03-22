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
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(user: TwitterUser) {
        self.nameLabel.text = user.name
        self.screenNameLabel.text = "@\(user.screenName)"
        
        self.iconImageView.sd_setImageWithURL(NSURL(string: user.profileImageURL)!)
        let url = NSURL(string: user.profileImageURL)
        SDWebImageDownloader.sharedDownloader().downloadImageWithURL(url, options: [], progress: nil,
                completed: { [weak self] (image, data, error, finished) in
                    dispatch_async(dispatch_get_main_queue(), {
                        self!.iconImageView.image = image
                    })
            })
        
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
            newCountLabel.text = user.newCount() <= 100 ? String(user.newCount()) : "many"
        } else {
            newCountLabel.hidden = true
        }
    }
}
