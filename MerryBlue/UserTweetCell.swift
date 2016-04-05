import UIKit
import SDWebImage
import TwitterKit

class UserTweetCell: UITableViewCell {
    @IBOutlet weak var tweetTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCell(tweet: TWTRTweet) {
        self.tweetTextLabel.text = tweet.text
    }

}
