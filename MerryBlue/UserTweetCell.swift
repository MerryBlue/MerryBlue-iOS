import UIKit
import SDWebImage
import TwitterKit

class UserTweetCell: UITableViewCell {
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var namesLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var backgroundWrapView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!

    var scaled = false

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
        self.scaled = false
        SDWebImageDownloader.setImageSync(self.userImageView, url: NSURL(string: tweet.author.profileImageURL)!)

        self.namesLabel.textColor = UIColor.blackColor()
        self.tweetTextLabel.textColor = UIColor.blackColor()
        self.backgroundImageView.image = nil
        self.backgroundWrapView.backgroundColor = UIColor.whiteColor()
        if tweet.imageURLs.count > 0 {
            self.backgroundImageView.sd_setImageWithURL(
                NSURL(string: tweet.imageURLs[0]),
                completed: { (image, error, sDImageCacheType, url) -> Void in
                    self.backgroundImageView.image = image
                    let cutRect = CGRect(
                        x: (image.size.width - self.frame.width) / 2,
                        y: (image.size.height  - self.frame.height)/2,
                        width: self.frame.width,
                        height: self.frame.height)
                    let cropCGImageRef = CGImageCreateWithImageInRect(image.CGImage, cutRect)
                    self.backgroundImageView.image = UIImage(CGImage: cropCGImageRef!)

                    self.tweetTextLabel.textColor = UIColor.whiteColor()
                    self.namesLabel.textColor = UIColor.whiteColor()
                    self.backgroundWrapView.backgroundColor = UIColor.blackColor()
                    SDWebImageManager.sharedManager().imageCache.storeImage(image, forKey: url.absoluteString)
                })
        }
        if !self.scaled {
            self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height + 50)
            self.scaled = true
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
