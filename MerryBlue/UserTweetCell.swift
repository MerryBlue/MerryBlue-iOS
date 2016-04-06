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
        SDWebImageDownloader.setImageSync(self.userImageView, url: NSURL(string: tweet.author.profileImageURL)!)
        if tweet.imageURLs.count > 0 {
            SDWebImageDownloader.setImageSync(self.backgroundImageView, url: NSURL(string: tweet.imageURLs[0])!)
            self.tweetTextLabel.textColor = UIColor.whiteColor()
            self.namesLabel.textColor = UIColor.whiteColor()
            self.backgroundWrapView.backgroundColor = UIColor.blackColor()
        }
        // rectangle views
        // if tweet.imageURLs.count > 0 {
        //     let w = Int(imagesView.frame.width)
        //     imagesView.frame = CGRect(x: 0, y: 0, width: w, height: tweet.imageURLs.count * 40)
        //     for (i, url) in tweet.imageURLs.enumerate() {
        //         // add dinamic image count
        //         let imageView = UIImageView(frame: CGRect(x: 0, y: i * 40, width: w, height: 40))
        //         imagesView.addSubview(imageView)
        //         SDWebImageDownloader.setImageSync(imageView, url: NSURL(string: url)!)
        //     }
        // }
    }

}
