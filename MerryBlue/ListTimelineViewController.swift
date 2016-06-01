import UIKit
import TwitterKit

class ListTimelineViewController: UIViewController {
    var delegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var switchListButton: UIBarButtonItem!

    var refreshControl: UIRefreshControl!

    var tweets: [MBTweet]!

    var cacheHeights = [CGFloat]()
    var list: MBTwitterList!

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
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...") // Loading中に表示する文字を決める
        refreshControl.addTarget(self, action: #selector(ListTimelineViewController.pullToRefresh), forControlEvents:.ValueChanged)
        self.tableView.addSubview(refreshControl)

        self.tableView.estimatedRowHeight = 20

        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    func pullToRefresh() {
        refreshControl.endRefreshing()
        self.requestTimeline()
    }

    func requestTimeline() {
        if self.list.isTimelineTabEnable() {
            _ = Twitter.sharedInstance().requestListTimeline(list)
                .subscribeNext({ (tweets: [MBTweet]) in
                    self.setupTweets(tweets)
                })
        } else {
            let tweets = [MBTweet()]
            self.setupTweets(tweets)
        }
    }


    func openListsChooser() {
        guard let slideMenu = self.slideMenuController() else {
            print("Error: HomeView hove not Slidebar")
            return
        }
        slideMenu.openLeft()
    }

    private func setNavigationBar() {
        guard let _ = ListService.sharedInstance.selectHomeList() else {
            print("Error: no wrapperd navigation controller")
            return
        }
        self.switchListButton.target = self
        self.switchListButton.action = #selector(ListTimelineViewController.openListsChooser)
    }

    func goBlack() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func viewDidAppear(animated: Bool) {
        guard let _ = ListService.sharedInstance.selectHomeList() else {
            goBlack()
            return
        }
        self.bgViewHeight = 150
        self.updateList()
    }

    func setupTabbarItemState() {
        guard let items: [UITabBarItem] = self.tabBarController!.tabBar.items,
            list = ListService.sharedInstance.selectHomeList()
            where items.count == 2 else { return }
        items[0].enabled = list.isHomeTabEnable()
        items[1].enabled = list.isTimelineTabEnable()
    }

    func didClickImageView(recognizer: UIGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            let nextViewController = StoryBoardService.sharedInstance.photoViewController()
            nextViewController.viewerImgUrl = NSURL(string: imageView.sd_imageURL().absoluteString + ":orig")
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }

    internal func updateList() {
        guard let list = ListService.sharedInstance.selectHomeList() else {
            self.openListsChooser()
            return
        }
        if let nowList = self.list where nowList.equalItem(list) {
            return
        }
        self.list = list
        self.setupTabbarItemState()
        self.navigationItem.title = list.name
        self.activityIndicator.startAnimating()
        self.tableView.contentOffset = CGPoint(x: 0, y: -self.tableView.contentInset.top)
        self.requestTimeline()
    }

    override func viewWillDisappear(animated: Bool) {
        self.slideMenuController()?.removeLeftGestures()
    }

    override func viewWillAppear(animated: Bool) {
        self.slideMenuController()?.addLeftGestures()
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let isBouncing = (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) && self.tableView.dragging
        if isBouncing && !isUpdating && self.list.isTimelineTabEnable() {
            isUpdating = true
            activityIndicator.startAnimating()
            _ = Twitter.sharedInstance().requestListTimelineNext(self.list, beforeTweet: tweets.last!)
                .subscribeNext({ (tweets: [MBTweet]) in
                    self.setupTweets(self.tweets + tweets)
                })
        }
    }

    func setupTweets(tweets: [MBTweet]) {
        self.tweets = tweets
        self.tableView.reloadData()
        self.activityIndicator.stopAnimating()
        self.isUpdating = false
    }

}

extension ListTimelineViewController: UITableViewDelegate {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tws = tweets else { return 0 }
        return tws.count
    }

}

extension ListTimelineViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCellWithIdentifier("tweet", forIndexPath: indexPath) as? UserTweetCell)!
        let tweet = tweets[indexPath.row]
        if !self.list.isTimelineTabEnable() {
            cell.setInfoCell(self.list)
            return cell
        } else {
            cell.setCell(tweet)
        }
        for view in cell.imageStackView.subviews {
            let recognizer = UITapGestureRecognizer(target:self, action: #selector(ListTimelineViewController.didClickImageView(_:)))
            view.addGestureRecognizer(recognizer)
        }
        return cell
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tweet = tweets[indexPath.row]
        self.delegate.showTweet = tweet
        self.navigationController?.pushViewController(StoryBoardService.sharedInstance.showTweetView(), animated: true)
    }

}
