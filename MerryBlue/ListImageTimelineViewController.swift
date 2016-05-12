import UIKit
import TwitterKit

class ListImageTimelineViewController: UIViewController {
    var delegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // @IBOutlet weak var switchListButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!

    var refreshControl: UIRefreshControl!

    var tweets = [MBTweet]()

    var cacheHeights = [CGFloat]()
    var list: MBTwitterList!

    var isUpdating = true
    var bgViewHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        self.setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // ====== setup methods ======

    func setupTableView() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...") // Loading中に表示する文字を決める
        refreshControl.addTarget(self, action: #selector(ListImageTimelineViewController.pullToRefresh), forControlEvents:.ValueChanged)
        self.collectionView.addSubview(refreshControl)
        // self.tableView.estimatedRowHeight = 20
        // self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    func pullToRefresh() {
        refreshControl.endRefreshing()
        if !list.isTimelineTabEnable() {
            presentViewController(AlertManager.sharedInstantce.disableTabSpecialTab(), animated: true, completion: nil)
            self.setupTweets([])
            self.navigationController?.tabBarController?.selectedIndex = 1
            return
        }
        requestListTimeline(list)
    }

    func requestListTimeline(list: MBTwitterList) {
        _ = Twitter.sharedInstance().requestSearchTweets("", list: list, beforeID: nil, filterImage: true)
            .subscribeNext({ (tweets: [MBTweet]) in
                self.setupTweets(tweets)
        })
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
        // self.switchListButton.target = self
        // self.switchListButton.action = #selector(ListImageTimelineViewController.openListsChooser)
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
            self.setupTweets([])
            presentViewController(AlertManager.sharedInstantce.listMemberLimit(), animated: true, completion: nil)
            self.navigationController?.tabBarController?.selectedIndex = 0
            return
        }
        self.activityIndicator.startAnimating()
        requestListTimeline(list)
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
        requestListTimeline(list)
    }

    override func viewWillDisappear(animated: Bool) {
        self.slideMenuController()?.removeLeftGestures()
    }

    override func viewWillAppear(animated: Bool) {
        self.slideMenuController()?.addLeftGestures()
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        var isBouncing = (self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.bounds.size.height)) && self.collectionView.dragging
        // TODO: remove
        isBouncing = false
        if isBouncing && !isUpdating {
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
        self.collectionView.reloadData()
        self.activityIndicator.stopAnimating()
        self.isUpdating = false
    }

}


extension ListImageTimelineViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCellWithReuseIdentifier("image-cell", forIndexPath: indexPath) as? ImageCell)!
        let tweet = self.tweets[indexPath.row]
        cell.image.sd_setImageWithURL(NSURL(string: tweet.imageURLs[0]), placeholderImage: AssetSertvice.sharedInstance.iconIndicator)
        cell.backgroundColor = UIColor.blackColor()
        return cell
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tweets.count
    }

}
