import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    func setCellInfo(info: ImageCellInfo) {
        self.backgroundColor = UIColor.blackColor()
        self.imageView.contentMode = .ScaleAspectFill
        self.imageView.sd_setImageWithURL(NSURL(string: info.imageURL), placeholderImage: AssetSertvice.sharedInstance.iconIndicator)
        let tweet = info.tweet.sourceTweet()
        self.ownerImageView.sd_setImageWithURL(NSURL(string: tweet.author.profileImageMiniURL), placeholderImage: AssetSertvice.sharedInstance.iconIndicator)
        // self.countLabel.text = String(info.counts)
    }

}
