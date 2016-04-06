import UIKit
import SDWebImage
import TwitterKit

class UserTweetCell: UITableViewCell {
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var namesLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var backgroundWrapView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!

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

        self.namesLabel.textColor = UIColor.grayColor()
        self.tweetTextLabel.textColor = UIColor.blackColor()
        self.backgroundImageView.image = nil
        self.backgroundImageView.contentMode = .ScaleAspectFill
        self.backgroundImageView.clipsToBounds = false
        self.backgroundWrapView.backgroundColor = UIColor.whiteColor()
        if tweet.imageURLs.count > 0 {
            self.namesLabel.textColor = UIColor.whiteColor()
            self.tweetTextLabel.textColor = UIColor.whiteColor()
            self.backgroundWrapView.backgroundColor = UIColor.blackColor()
            self.backgroundImageView.sd_setImageWithURL(
                NSURL(string: tweet.imageURLs[0]),
                placeholderImage: AssetSertvice.sharedInstance.loadingImage,
                completed: { (image, error, sDImageCacheType, url) -> Void in
                    self.backgroundImageView.frame = self.frame
                    self.backgroundImageView.image = image
                })
        }

    }

}
