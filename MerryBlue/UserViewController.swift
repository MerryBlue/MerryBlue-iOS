import TwitterKit
import SDWebImage

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var delegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userHeaderImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var nameLable: UILabel!


    var refreshControl: UIRefreshControl!

    var user: TwitterUser!
    var tweets: [TWTRTweet]!

    var cacheHeights = [CGFloat]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        self.setupTableView()
    }

    // ====== setup methods ======

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...") // Loading中に表示する文字を決める
        refreshControl.addTarget(self, action: #selector(HomeViewController.pullToRefresh), forControlEvents:.ValueChanged)
        self.tableView.addSubview(refreshControl)
        self.tableView.estimatedRowHeight = 20
        self.tableView.rowHeight = UITableViewAutomaticDimension
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
        self.user = user
        self.setUser()
        self.activityIndicator.startAnimating()
        _ = TwitterManager.requestUserTimeline(user)
             .subscribeNext({ (tweets: [TWTRTweet]) in
                self.tweets = tweets
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
             })
    }

    func setUser() {
        self.nameLable.text = user.name
        self.screenNameLabel.text = user.screenName
        SDWebImageDownloader
            .sharedDownloader()
            .downloadImageWithURL(
                NSURL(string: user.profileImageURL),
                options: [], progress: nil,
                completed: {
                    [weak self] (image, data, error, finished) in
                    guard let _ = self else { return }
                    dispatch_async(dispatch_get_main_queue()) { self?.userImageView.image = image }
                })
        SDWebImageDownloader
            .sharedDownloader()
            .downloadImageWithURL(
                NSURL(string: self.user.profileBannerImageURL),
                options: [], progress: nil,
                completed: {
                    [weak self] (image, data, error, finished) in
                    guard let _ = self else { return }
                    dispatch_async(dispatch_get_main_queue()) { self?.userHeaderImageView.image = image }
                })
    }

    // ====== tableview methods ======

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tws = tweets else { return 0 }
        return tws.count
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCellWithIdentifier("tweet", forIndexPath: indexPath) as? UserTweetCell)!
        cell.setCell(tweets[indexPath.row])
        return cell
    }

    // func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //     if self.cacheHeights.count <= indexPath.row {
    //         var cell = tableView.cellForRowAtIndexPath(indexPath)
    //         var height = cell
    //     }
    //     return height
    // }

}
