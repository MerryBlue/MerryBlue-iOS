import UIKit
import TwitterKit

// プロトコルを追加
class PhotoViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var imageViewWrap: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var tweetInfoView: UIView!
    @IBOutlet weak var tweetUserIconImageView: UIImageView!
    @IBOutlet weak var tweetNamesLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!

    var tweet: TWTRTweet!
    var viewerImgUrl: NSURL!
    var viewerImg: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 8
        self.scrollView.scrollEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = true
        self.scrollView.showsVerticalScrollIndicator = true

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotoViewController.doubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.imageViewWrap.userInteractionEnabled = true
        self.imageViewWrap.addGestureRecognizer(doubleTapGesture)
        // let singleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoViewController.singleTap(_:)))
        // singleTapGesture.numberOfTapsRequired = 1
        // self.imageViewWrap.addGestureRecognizer(singleTapGesture)
        let longpressGesture = UILongPressGestureRecognizer(target: self, action: #selector(PhotoViewController.longPress(_:)))
        self.imageViewWrap.addGestureRecognizer(longpressGesture)
        self.tweetInfoView.alpha = 0
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }

    override func viewDidAppear(animated: Bool) {
        self.activityIndicator.startAnimating()
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.sd_setImageWithURL(self.viewerImgUrl, completed: {
            (image, error, sDImageCacheType, url) -> Void in
            self.activityIndicator.stopAnimating()
            })
        self.setTweet()
    }

    func setTweet() {
        if let tweet = self.tweet {
            self.tweetUserIconImageView.sd_setImageWithURL(NSURL(string: tweet.author.profileImageURL))
            self.tweetTextLabel.text = tweet.prettyText()
            self.tweetNamesLabel.text = "\(tweet.author.name)・@\(tweet.author.screenName)・\(tweet.createdAt.toFuzzy())"
            self.tweetInfoView.alpha = 1
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }

    // func singleTap(gesture: UITapGestureRecognizer) -> Void {
    //     if let _ = self.tweet {
    //         self.tweetInfoView.alpha = (self.tweetInfoView.alpha + 1) % 2
    //     }
    // }

    func longPress(gesture: UITapGestureRecognizer) -> Void {
        guard let image = self.imageView.image else {
            return
        }
        let activityItems = [image]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        let excludedActivityTypes: [String] = []
        activityVC.excludedActivityTypes = excludedActivityTypes
        self.presentViewController(activityVC, animated: true, completion: nil)
    }

    func doubleTap(gesture: UITapGestureRecognizer) -> Void {

        // print(self.scrollView.zoomScale)
        if self.scrollView.zoomScale < self.scrollView.maximumZoomScale {
            let newScale: CGFloat = self.scrollView.zoomScale * 3
            let zoomRect: CGRect = self.zoomRectForScale(newScale, center: gesture.locationInView(gesture.view))
            self.scrollView.zoomToRect(zoomRect, animated: true)
        } else {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
            self.tweetInfoView.alpha = 1
        }
    }

    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect: CGRect = CGRect()
        zoomRect.size.height = self.scrollView.frame.size.height / scale
        zoomRect.size.width = self.scrollView.frame.size.width / scale

        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0

        if self.scrollView.zoomScale == self.scrollView.maximumZoomScale {
            self.tweetInfoView.alpha = 1
        } else {
            self.tweetInfoView.alpha = 0
        }

        return zoomRect
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ピンチイン・ピンチアウト時に呼ばれる
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageViewWrap
    }

}
