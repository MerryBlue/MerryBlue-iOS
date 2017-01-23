import UIKit
import TwitterKit

class TweetViewController: UIViewController {

    var delegate = (UIApplication.shared.delegate as? AppDelegate)!

    // @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var tweetTextLabel: UILabel!

    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var imageStackViewHeight: NSLayoutConstraint!

    @IBOutlet weak var favoriteButton: UIButton!
    @IBAction func favoriteButtonTapped(_ sender: AnyObject) {
        _ = Twitter.sharedInstance().requestToggleLikeTweet(tweet)
            .subscribeNext({ (tweet: MBTweet) in
                self.tweet = tweet
                self.loadLikeButton()
            })
    }

    @IBOutlet weak var retweetButton: UIButton!
    @IBAction func retweetButtonTapped(_ sender: AnyObject) {
        if tweet.sourceTweet().isOwnTweet() {
            return
        }
        if !tweet.sourceTweet().isRetweeted {
            _ = Twitter.sharedInstance().requestRetweet(tweet)
                .subscribeNext({ (tweet: MBTweet) in
                    self.tweet = tweet
                    self.loadRetweetButton()
                })
        } else {
            _ = Twitter.sharedInstance().requestUnretweet(tweet)
                .subscribeNext({ (tweet: MBTweet) in
                    self.tweet = tweet
                    let col = UIColor.grayColor()
                    self.retweetButton.setTitleColor(col, forState: .Normal)
                    self.retweetButton.tintColor = col
                })
        }
    }
    @IBOutlet weak var openButton: UIButton!
    @IBAction func openButtonTapped(_ sender: AnyObject) {
        // let twitterUrl = NSURL(string: "twitter://status?id=\(tweet.tweetID)")!
        let url = URL(string: "https://twitter.com/chomado/status/\(tweet.tweetID)")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.openURL(url!)
        } else {
            AlertManager.sharedInstantce.disableOpenApp()
        }
    }

    var tweet: MBTweet!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        guard let tweet = delegate.showTweet else {
            return
        }
        let sourceTweet = tweet.sourceTweet()
        self.tweet = tweet
        // _ = Twitter.sharedInstance().requestTweetConversions(tweet).subscribe()
        self.tweetTextLabel.text = sourceTweet.text
        self.nameLabel.text = sourceTweet.author.name
        self.screenNameLabel.text = "@\(sourceTweet.author.screenName)"

        self.userImageView.sd_setImageWithURL(URL(string: sourceTweet.author.profileImageURL), placeholderImage: AssetSertvice.sharedInstance.loadingImage)

        // images set
        let imageHeight: CGFloat = 100
        self.imageStackViewHeight.constant = CGFloat(tweet.imageURLs.count) * imageHeight

        _ = self.imageStackView.subviews.map { $0.removeFromSuperview() }
        if tweet.hasMedia() && self.imageStackView.subviews.count == 0 {
            for (i, url) in tweet.imageURLs.enumerated() {
                let recognizer = UITapGestureRecognizer(target:self, action: #selector(TweetViewController.didClickImageView(_:)))
                let imageView = UIImageView()
                imageView.addGestureRecognizer(recognizer)
                imageView.isUserInteractionEnabled = true
                // imageView.frame = CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageHeight)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.sd_setImageWithURL(URL(string: url), placeholderImage: AssetSertvice.sharedInstance.iconIndicator)
                self.imageStackView.insertArrangedSubview(imageView, at: i)
            }
        }
        loadLikeButton()
        loadRetweetButton()
    }

    func loadLikeButton() {
        let sourceTweet = tweet.sourceTweet()
        if sourceTweet.likeCount > 0 {
            favoriteButton.setTitle(String(sourceTweet.likeCount), for: UIControlState())
        }
        let col = sourceTweet.isLiked ? MBColor.Dark : UIColor.grayColor()
        favoriteButton.setTitleColor(col, forState: .Normal)
        favoriteButton.tintColor = col

    }

    func loadRetweetButton() {
        let sourceTweet = tweet.sourceTweet()
        if sourceTweet.retweetCount > 0 {
            retweetButton.setTitle(String(sourceTweet.retweetCount), for: UIControlState())
        }
        var col = UIColor.gray
        if sourceTweet.isRetweeted {
            col = MBColor.Dark
        } else if sourceTweet.isOwnTweet() {
            col = UIColor.lightGray
        }
        retweetButton.setTitleColor(col, for: UIControlState())
        retweetButton.tintColor = col

    }

    func didClickImageView(_ recognizer: UIGestureRecognizer) {
        guard let imageView: UIImageView = recognizer.view as? UIImageView else {
            return
        }
        let nextViewController = StoryBoardService.sharedInstance.photoViewController()
        nextViewController.viewerImgUrl = URL(string: imageView.sd_imageURL().absoluteString + ":orig")
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

}
