import UIKit
import TwitterKit
import FontAwesomeKit

class TweetViewController: UIViewController {

    var delegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!

    // @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var tweetTextLabel: UILabel!

    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var imageStackViewHeight: NSLayoutConstraint!

    @IBOutlet weak var favoriteButton: UIButton!
    @IBAction func favoriteButtonTapped(sender: AnyObject) {
        _ = TwitterManager.requestToggleLikeTweet(tweet)
            .subscribeNext({ (tweet: MBTweet) in
                self.tweet = tweet
                self.loadLikeButton()
            })
    }

    @IBOutlet weak var retweetButton: UIButton!
    @IBAction func retweetButtonTapped(sender: AnyObject) {
        _ = TwitterManager.requestToggleLikeTweet(tweet)
            .subscribeNext({ (tweet: MBTweet) in
                self.tweet = tweet
                self.loadRetweetButton()
            })
    }
    @IBOutlet weak var openButton: UIButton!
    @IBAction func openButtonTapped(sender: AnyObject) {
        // let twitterUrl = NSURL(string: "twitter://status?id=\(tweet.tweetID)")!
        let url = NSURL(string: "https://twitter.com/chomado/status/\(tweet.tweetID)")
        if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        } else {
            AlertManager.sharedInstantce.disableOpenApp()
        }
    }

    var hasMedia: Bool!

    var tweet: MBTweet!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        guard let tweet = delegate.showTweet else {
            return
        }
        let sourceTweet = tweet.sourceTweet()
        self.tweet = tweet
        // _ = TwitterManager.requestTweetConversions(tweet).subscribe()
        self.tweetTextLabel.text = sourceTweet.text
        self.nameLabel.text = sourceTweet.author.name
        self.screenNameLabel.text = "@\(sourceTweet.author.screenName)"
        self.userImageView.sd_setImageWithURL(NSURL(string: sourceTweet.author.profileImageURL), placeholderImage: AssetSertvice.sharedInstance.loadingImage)

        // images set
        self.hasMedia = tweet.imageURLs.count > 0
        let imageHeight: CGFloat = 100
        self.imageStackViewHeight.constant = CGFloat(tweet.imageURLs.count) * imageHeight

        _ = self.imageStackView.subviews.map { $0.removeFromSuperview() }
        if hasMedia! && self.imageStackView.subviews.count == 0 {
            for (i, url) in tweet.imageURLs.enumerate() {
                let recognizer = UITapGestureRecognizer(target:self, action: #selector(TweetViewController.didClickImageView(_:)))
                let imageView = UIImageView()
                imageView.addGestureRecognizer(recognizer)
                imageView.userInteractionEnabled = true
                // imageView.frame = CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageHeight)
                imageView.contentMode = .ScaleAspectFill
                imageView.clipsToBounds = true
                imageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "icon-indicator"))
                self.imageStackView.insertArrangedSubview(imageView, atIndex: i)
            }
        }
        loadLikeButton()
        loadRetweetButton()
    }

    func loadLikeButton() {
        let sourceTweet = tweet.sourceTweet()
        if sourceTweet.likeCount > 0 {
            favoriteButton.setTitle(String(sourceTweet.likeCount), forState: .Normal)
            let col = sourceTweet.isLiked ? MBColor.Dark : UIColor.grayColor()
            favoriteButton.setTitleColor(col, forState: .Normal)
            favoriteButton.tintColor = col
        }

    }

    func loadRetweetButton() {
        let sourceTweet = tweet.sourceTweet()
        if sourceTweet.retweetCount > 0 {
            retweetButton.setTitle(String(sourceTweet.retweetCount), forState: .Normal)
            let col = sourceTweet.isRetweeted ? MBColor.Dark : UIColor.grayColor()
            retweetButton.setTitleColor(col, forState: .Normal)
            retweetButton.tintColor = col
        }
        retweetButton.tintColor = sourceTweet.isRetweeted ? MBColor.Dark : UIColor.grayColor()

    }

    func didClickImageView(recognizer: UIGestureRecognizer) {
        guard let imageView: UIImageView = recognizer.view as? UIImageView else {
            return
        }
        let nextViewController = StoryBoardService.sharedInstance.photoViewController()
        nextViewController.viewerImgUrl = NSURL(string: imageView.sd_imageURL().absoluteString + ":orig")
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

}
