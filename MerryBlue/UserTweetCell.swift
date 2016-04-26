import UIKit
import SDWebImage
import TwitterKit

class UserTweetCell: UITableViewCell {
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var namesLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!

    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var imageStackViewHeight: NSLayoutConstraint!

    var hasMedia: Bool!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCell(tweet: MBTweet) {
        let sourceTweet = tweet.sourceTweet()
        self.tweetTextLabel.text = sourceTweet.text
        self.namesLabel.text = "\(sourceTweet.author.name)・@\(sourceTweet.author.screenName)・\(tweet.createdAt.toFuzzy())"
        self.userImageView.sd_setImageWithURL(NSURL(string: sourceTweet.author.profileImageURL), placeholderImage: AssetSertvice.sharedInstance.loadingImage)

        self.hasMedia = tweet.imageURLs.count > 0
        let imageHeight: CGFloat = 100
        self.imageStackViewHeight.constant = CGFloat(tweet.imageURLs.count) * imageHeight

        _ = self.imageStackView.subviews.map { $0.removeFromSuperview() }
        if hasMedia! && self.imageStackView.subviews.count == 0 {
            for (i, url) in tweet.imageURLs.enumerate() {
                let imageView = UIImageView()
                imageView.userInteractionEnabled = true
                // imageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: imageHeight)
                imageView.contentMode = .ScaleAspectFill
                imageView.clipsToBounds = true
                imageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: AssetSertvice.sharedInstance.iconIndicator)
                self.imageStackView.insertArrangedSubview(imageView, atIndex: i)
            }
        }

    }

}
