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

    var tweet: MBTweet!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        guard let tweet = delegate.showTweet else {
            return
        }
        self.tweet = tweet
        self.tweetTextLabel.text = tweet.text
        self.nameLabel.text = tweet.author.name
        self.screenNameLabel.text = "@\(tweet.author.screenName)"
        self.userImageView.sd_setImageWithURL(NSURL(string: tweet.author.profileImageURL), placeholderImage: AssetSertvice.sharedInstance.loadingImage)
    }

}
