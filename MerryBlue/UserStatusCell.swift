import Foundation
import UIKit

class UserStatusCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(user: TwitterUser) {
        self.nameLabel.text = user.name
        self.screenNameLabel.text = user.screenName
        do {
            let imageData: NSData = try NSData(contentsOfURL: NSURL(string: user.profileImageURL)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            self.iconImageView.image = UIImage(data:imageData)
        } catch {
            print("Error: Image request invalid")
        }
        guard let status = user.lastStatus else {
            self.tweetTextView.text = "ツイートが読み込めませんでした"
            self.timeElapsedLabel.text = "----/--/-- --:--:--"
            return
        }
        self.tweetTextView.text = status.text.lines[0]
        if let line: String = status.text.lines[safe: 1] {
            self.tweetTextView.text = self.tweetTextView.text + "\n" + line
        }
        let df = NSDateFormatter()
        df.dateFormat = "yyyy/MM/dd HH:mm:ss"
        self.timeElapsedLabel.text = df.stringFromDate(status.createdAt)
    }
}
