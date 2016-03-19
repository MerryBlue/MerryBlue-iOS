import Foundation
import UIKit

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
        do {
            let imageData: NSData = try NSData(contentsOfURL: NSURL(string: user.profileImageURL)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            self.iconImageView.image = UIImage(data:imageData)
        } catch {
            print("Error: Image request invalid")
        }
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
