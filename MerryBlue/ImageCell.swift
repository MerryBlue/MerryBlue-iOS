import UIKit
import TwitterKit

class ImageCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var ownerImageView: UIImageView!
    // @IBOutlet weak var countLabel: UILabel!

    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var rtCountLabel: UILabel!
    @IBOutlet weak var favCountLabel: UILabel!
    var tweet: TWTRTweet!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    func setCellInfo(_ info: ImageCellInfo) {
        self.backgroundColor = UIColor.black
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.sd_setImageWithURL(URL(string: info.imageURL), placeholderImage: AssetSertvice.sharedInstance.iconIndicator)
        self.tweet = info.tweet.sourceTweet()
        self.ownerImageView.sd_setImageWithURL(URL(string: tweet.author.profileImageURL), placeholderImage: AssetSertvice.sharedInstance.iconIndicator)
        // self.countLabel.text = String(info.counts)
        self.favCountLabel.text = tweet.miniDisplayLikeCount()
        self.rtCountLabel.text = tweet.miniDisplayRetweetCount()
    }

    func setVisible(_ isVisible: Bool) {
        self.infoView.alpha = isVisible ? 1 : 0
    }

}
