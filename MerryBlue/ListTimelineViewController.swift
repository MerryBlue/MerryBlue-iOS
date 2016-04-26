import UIKit
import TwitterKit
import FontAwesomeKit

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
        // refreshControl = UIRefreshControl()
        // refreshControl.attributedTitle = NSAttributedString(string: "Loading...") // Loading中に表示する文字を決める
        // refreshControl.addTarget(self, action: #selector(ListTimelineViewController.pullToRefresh), forControlEvents:.ValueChanged)
        // self.tableView.addSubview(refreshControl)
        // self.refreshControl = nil

        self.tableView.estimatedRowHeight = 20

        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    func pullToRefresh() {
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
        if self.tweets != nil {
            return
        }
        self.list = list
        self.title = "Timeline"
        self.bgViewHeight = 150
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
        if let _ = self.list where self.list.equalItem(list) {
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
        self.list = list
    }

    override func viewWillDisappear(animated: Bool) {
        self.slideMenuController()?.removeLeftGestures()
    }

    override func viewWillAppear(animated: Bool) {
        self.slideMenuController()?.addLeftGestures()
    }


}

extension ListTimelineViewController: UITableViewDelegate {

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

extension ListTimelineViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tws = tweets else { return 0 }
        return tws.count
    }

}
