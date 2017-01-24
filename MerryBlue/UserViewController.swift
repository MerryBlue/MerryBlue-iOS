import Foundation
import TwitterKit
import UIKit
import SDWebImage
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class UserViewController: UIViewController {
    var delegate = (UIApplication.shared.delegate as? AppDelegate)!
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

        self.tableView.estimatedRowHeight = 20

        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    func pullToRefresh() {
    }


    fileprivate func setNavigationBar() {
        guard let _ = self.navigationController else {
            print("Error: no wrapperd navigation controller")
            return
        }
    }

    func goBlack() {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        guard let user = delegate.userViewUser else {
            goBlack()
            return
        }
        if self.tweets != nil {
            return
        }
        self.user = user
        self.title = self.user.screenNameWithAt()
        self.newCount = delegate.userViewNewCount! 
        self.setUser()
        self.bgViewHeight = 150
        self.activityIndicator.startAnimating()
        _ = Twitter.sharedInstance().requestUserTimeline(user)
            .subscribe(onNext: {(tweets: [MBTweet]) in
                self.tweets = tweets
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.isUpdating = false
            })
    }

    func setUser() {
        self.nameLable.text = user.name
        self.screenNameLabel.text = user.screenName
        self.userImageView.sd_setImage(with: URL(string: user.profileImageURL), placeholderImage: AssetSertvice.sharedInstance.loadingImage)

        if let url = user.profileBannerImageURL, !url.isEmpty {
            self.userHeaderImageView.clipsToBounds = true
            self.userHeaderImageView.contentMode = .scaleAspectFill
            self.userHeaderImageView.sd_setImage(with: URL(string: url), placeholderImage: AssetSertvice.sharedInstance.loadingImage)
        } else {
            self.userHeaderImageView.image = nil
            self.backgroundView.layer.backgroundColor = MBColor.Main.cgColor
        }
    }

    // ====== readmore support ======
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isBouncing = (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) && self.tableView.isDragging
        if isBouncing && !isUpdating {
            isUpdating = true
            activityIndicator.startAnimating()
            _ = Twitter.sharedInstance().requestUserTimelineNext(user, beforeTweet: tweets.last!)
                .subscribe(onNext: { (tweets: [MBTweet]) in
                    self.tweets.append(contentsOf: tweets)
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

    override func didMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        guard let _ = TwitterManager.getUserID() else {
            return
        }
    }

    func didClickimageView(_ recognizer: UIGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            let nextViewController = StoryBoardService.sharedInstance.photoViewController()
            nextViewController.viewerImgUrl = URL(string: imageView.sd_imageURL().absoluteString + ":orig")
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }

}

extension UserViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "tweet", for: indexPath) as? UserTweetCell)!
        let tweet = tweets[indexPath.row]
        cell.setCell(tweet)
        for view in cell.imageStackView.subviews {
            let recognizer = UITapGestureRecognizer(target:self, action: #selector(UserViewController.didClickimageView(_:)))
            view.addGestureRecognizer(recognizer)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: 0.0, width: 5.0, height: cell.frame.height)
        bottomLine.backgroundColor = indexPath.row < newCount ? MBColor.Sub.cgColor : UIColor.white.cgColor
        cell.layer.addSublayer(bottomLine)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tweet = tweets[indexPath.row]
        self.delegate.showTweet = tweet
        self.navigationController?.pushViewController(StoryBoardService.sharedInstance.showTweetView(), animated: true)
    }

}

extension UserViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tws = tweets else { return 0 }
        return tws.count
    }

}
