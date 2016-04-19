import Foundation
import TwitterKit
import SDWebImage

class UserViewController: UIViewController {
    var delegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userHeaderImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var nameLable: UILabel!

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet var backgroundViewHeight: NSLayoutConstraint!

    var refreshControl: UIRefreshControl!

    var user: TwitterUser!
    var newCount: Int!
    var tweets: [MBTweet]!

    var cacheHeights = [CGFloat]()

    var isUpdating = true
    var bgViewHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        self.setupTableView()
    }

    // ====== setup methods ======

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        // refreshControl = UIRefreshControl()
        // refreshControl.attributedTitle = NSAttributedString(string: "Loading...") // Loading中に表示する文字を決める
        // refreshControl.addTarget(self, action: #selector(UserViewController.pullToRefresh), forControlEvents:.ValueChanged)
        // self.tableView.addSubview(refreshControl)
        // self.refreshControl = nil

        let nib = UINib(nibName: "UserTweetCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "tweet")

        self.tableView.estimatedRowHeight = 20

        self.tableView.rowHeight = UITableViewAutomaticDimension

        // let recognizer = UITapGestureRecognizer()
        // self.tableView.addGestureRecognizer(recognizer)
    }

    func pullToRefresh() {
    }


    private func setNavigationBar() {
        guard let _ = self.navigationController else {
            print("Error: no wrapperd navigation controller")
            return
        }
    }

    func goBlack() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func viewDidAppear(animated: Bool) {
        guard let user = delegate.userViewUser else {
            goBlack()
            return
        }
        if self.tweets != nil {
            return
        }
        self.user = user
        self.title = self.user.screenNameWithAt()
        self.newCount = delegate.userViewNewCount! ?? 0
        self.setUser()
        self.bgViewHeight = 150
        self.activityIndicator.startAnimating()
        _ = TwitterManager.requestUserTimeline(user)
             .subscribeNext({ (tweets: [MBTweet]) in
                self.tweets = tweets
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.isUpdating = false
             })
    }

    func setUser() {
        self.nameLable.text = user.name
        self.screenNameLabel.text = user.screenName
        self.userImageView.sd_setImageWithURL(NSURL(string: user.profileImageURL), placeholderImage: AssetSertvice.sharedInstance.loadingImage)

        if let url = user.profileBannerImageURL where !url.isEmpty {
            self.userHeaderImageView.clipsToBounds = true
            self.userHeaderImageView.contentMode = .ScaleAspectFill
            self.userHeaderImageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "twttr-icn-tweet-place-holder-photo-error@3x.png"))
        } else {
            let gradientLayer: CAGradientLayer = CAGradientLayer()
            gradientLayer.colors = [user.color.CGColor, UIColor.blackColor().CGColor]
            gradientLayer.frame = self.backgroundView.bounds
            self.backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
            // self.backgroundView.backgroundColor = user.color
        }
    }

    // ====== readmore support ======
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let isBouncing = (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) && self.tableView.dragging
        if isBouncing && !isUpdating {
            isUpdating = true
            activityIndicator.startAnimating()
            _ = TwitterManager.requestUserTimelineNext(user, tweet: tweets.last!)
                .subscribeNext({ (tweets: [MBTweet]) in
                    self.tweets.appendContentsOf(tweets)
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.isUpdating = false
                })
        }

        let navHideRate: CGFloat = 1.618
        if self.tweets == nil || self.tableView.contentOffset.y <= 0 {
            backgroundViewHeight.constant = self.bgViewHeight
        } else if self.tableView.contentOffset.y * navHideRate <= self.bgViewHeight {
            backgroundViewHeight.constant = self.bgViewHeight - self.tableView.contentOffset.y * navHideRate
        } else {
            backgroundViewHeight.constant = 0
        }
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        guard let _ = TwitterManager.getUserID() else {
            return
        }
    }

}

extension UserViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCellWithIdentifier("tweet", forIndexPath: indexPath) as? UserTweetCell)!
        let tweet = tweets[indexPath.row]
        cell.setCell(tweet)
        return cell
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: 0.0, width: 5.0, height: cell.frame.height)
        bottomLine.backgroundColor = indexPath.row < newCount ? MBColor.Sub.CGColor : UIColor.whiteColor().CGColor
        cell.layer.addSublayer(bottomLine)
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tweet = tweets[indexPath.row]
        self.delegate.showTweet = tweet
        self.navigationController?.pushViewController(StoryBoardService.sharedInstance.showTweetView(), animated: true)
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {

        let replay = MBTableViewRowAction.new(UIImage(named: "icon-replay")!) {
            (action, indexPath) in
            print("replay")
            tableView.editing = false
        }

        let retweet = MBTableViewRowAction.new(UIImage(named: "icon-images")!) {
            (action, indexPath) in
            print("rt")
            tableView.editing = false
        }

        let favorite = MBTableViewRowAction.new(UIImage(named: "icon-favorite")!) {
            (action, indexPath) in
            print("favo")
            tableView.editing = false
        }

        let twitter = MBTableViewRowAction.new(UIImage(named: "icon-twitter-sq")!) {
            (action, indexPath) in
            print("favo")
            tableView.editing = false
        }

        return [twitter, favorite, retweet, replay]
    }

}

extension UserViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tws = tweets else { return 0 }
        return tws.count
    }

    // エディット機能の提供に必要なメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
}
