import UIKit
import SDWebImage
import TwitterKit

class UserTweetCell: UITableViewCell {
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var namesLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!

    @IBOutlet weak var mainImageView: UIImageView!

    var hasMedia: Bool!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCell(tweet: MBTweet) {
        var sourceTweet: TWTRTweet = tweet
        if tweet.isRetweet {
            sourceTweet = tweet.retweetedTweet
        }
        self.tweetTextLabel.text = sourceTweet.text
        self.namesLabel.text = "\(sourceTweet.author.name)・@\(sourceTweet.author.screenName)・\(tweet.createdAt.toFuzzy())"
        self.userImageView.sd_setImageWithURL(NSURL(string: sourceTweet.author.profileImageURL), placeholderImage: AssetSertvice.sharedInstance.loadingImage)

        self.mainImageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 0)
        self.mainImageView.image = nil
        self.hasMedia = tweet.imageURLs.count > 0
        if hasMedia! {
            self.mainImageView.userInteractionEnabled = true
            self.mainImageView.tag = 1
            self.mainImageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 100)
            self.mainImageView.contentMode = .ScaleAspectFill
            self.mainImageView.clipsToBounds = true
            self.mainImageView.backgroundColor = UIColor.blackColor()
            // self.imageBoxView.addSubview(mainImageView)

            self.mainImageView.sd_setImageWithURL(NSURL(string: tweet.imageURLs[0]), placeholderImage: UIImage(named: "icon-indicator"))
        }

    }

}
