import UIKit
import SDWebImage
import TwitterKit

class UserTweetCell: UITableViewCell {
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var namesLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!

    @IBOutlet weak var mainImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCell(tweet: MBTweet) {
        self.tweetTextLabel.text = tweet.text
        self.namesLabel.text = "\(tweet.author.name)・@\(tweet.author.screenName)・\(tweet.createdAt.toFuzzy())"
        self.userImageView.sd_setImageWithURL(NSURL(string: tweet.author.profileImageURL), placeholderImage: AssetSertvice.sharedInstance.loadingImage)

        self.mainImageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 0)
        self.mainImageView.image = nil
        if tweet.imageURLs.count > 0 {
            self.mainImageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 100)
            self.mainImageView.contentMode = .ScaleAspectFill
            self.mainImageView.clipsToBounds = true
            self.mainImageView.backgroundColor = UIColor.blackColor()
            // self.imageBoxView.addSubview(mainImageView)

            self.mainImageView.sd_setImageWithURL(NSURL(string: tweet.imageURLs[0]), placeholderImage: UIImage(named: "icon-indicator"))
        }

    }

}
