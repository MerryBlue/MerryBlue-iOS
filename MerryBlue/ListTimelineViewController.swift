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
        if !list.isTimelineTabEnable() {
            self.activityIndicator.stopAnimating()
            presentViewController(AlertManager.sharedInstantce.disableTabSpecialTab(), animated: true, completion: nil)
            self.tweets = []
            self.tableView.reloadData()
            refreshControl.endRefreshing()
            self.navigationController?.tabBarController?.selectedIndex = 1
            return
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
        guard let list = ListService.sharedInstance.selectHomeList() else {
            goBlack()
            return
        }
        self.list = list
        self.bgViewHeight = 150
        if !list.isTimelineTabEnable() {
            self.activityIndicator.stopAnimating()
            self.tweets = []
            self.tableView.reloadData()
            refreshControl.endRefreshing()
            presentViewController(AlertManager.sharedInstantce.listMemberLimit(), animated: true, completion: nil)
            self.navigationController?.tabBarController?.selectedIndex = 0
            return
        }
        self.activityIndicator.startAnimating()
        _ = Twitter.sharedInstance().requestListTimeline(list)
             .subscribeNext({ (tweets: [MBTweet]) in
                self.tweets = tweets
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.isUpdating = false
             })
    }

    func setupTabbarItemState() {
        guard let items: [UITabBarItem] = self.tabBarController!.tabBar.items,
            list = ListService.sharedInstance.selectHomeList()
            where items.count == 2 else { return }
        items[0].enabled = list.isHomeTabEnable()
        items[1].enabled = list.isTimelineTabEnable()
    }

    func didClickimageView(recognizer: UIGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            let nextViewController = StoryBoardService.sharedInstance.photoViewController()
            nextViewController.viewerImgUrl = NSURL(string: imageView.sd_imageURL().absoluteString + ":orig")
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        guard let _ = TwitterManager.getUserID() else {
            return
        }
        self.updateList()
    }

    internal func updateList() {
        guard let list = ListService.sharedInstance.selectHomeList() else {
            self.openListsChooser()
            return
        }
        self.setupTabbarItemState()
        self.list = list
        self.navigationItem.title = list.name
        if let nowList = self.list where nowList.equalItem(list) {
            return
        }
        self.activityIndicator.startAnimating()
        _ = Twitter.sharedInstance().requestListTimeline(list)
             .subscribeNext({ (tweets: [MBTweet]) in
                self.tweets = tweets
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.isUpdating = false
             })
    }

    override func viewWillDisappear(animated: Bool) {
        self.slideMenuController()?.removeLeftGestures()
    }

    override func viewWillAppear(animated: Bool) {
        self.slideMenuController()?.addLeftGestures()
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let isBouncing = (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) && self.tableView.dragging
        if isBouncing && !isUpdating {
            isUpdating = true
            activityIndicator.startAnimating()
            _ = Twitter.sharedInstance().requestListTimelineNext(self.list, beforeTweet: tweets.last!)
                .subscribeNext({ (tweets: [MBTweet]) in
                    self.tweets.appendContentsOf(tweets)
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.isUpdating = false
                })
        }
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
        cell.setCell(tweet)
        for view in cell.imageStackView.subviews {
            let recognizer = UITapGestureRecognizer(target:self, action: #selector(ListTimelineViewController.didClickimageView(_:)))
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
