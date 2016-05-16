import UIKit
import TwitterKit

enum ImageViewType: Int {
    case IncludeRT
    case ExcludeRT

    case Dummy

    func next() -> ImageViewType {
        return ImageViewType(rawValue: (self.rawValue + ImageViewType.Dummy.rawValue + 1) % ImageViewType.Dummy.rawValue)!
    }
}

class ListImageTimelineViewController: UIViewController {
    static let ColumnNum: CGFloat = 2

    var delegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var switchListButton: UIBarButtonItem!
    @IBOutlet weak var rtModeButton: UIBarButtonItem!
    @IBOutlet weak var infoModeButton: UIBarButtonItem!

    @IBOutlet weak var collectionView: UICollectionView!

    var refreshControl: UIRefreshControl!
    var rtMode: ImageViewType = .ExcludeRT
    var infoMode = true

    var tweets = [MBTweet]()
    var imageCellInfos = [ImageCellInfo]()

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
        _ = Twitter.sharedInstance().requestListImageTweets(list, includeRT: self.rtMode == .IncludeRT)
            .subscribeNext({ (tweets: [MBTweet]) in
                self.setupTweets(tweets)
        })
    }

    func toggleRTMode() {
        self.rtMode = self.rtMode.next()
        self.rtModeButton.tintColor = self.rtMode == .IncludeRT ? UIColor.whiteColor() : UIColor.grayColor()
        ConfigService.sharedInstance.updateImageViewModeType(TwitterManager.getUserID(), type: self.rtMode)
        requestListTimeline(self.list)
    }

    func toggleInfoMode() {
        self.infoMode = !self.infoMode
        self.infoModeButton.tintColor = self.infoMode ? UIColor.whiteColor() : UIColor.grayColor()
        ConfigService.sharedInstance.updateImageInfoModeType(TwitterManager.getUserID(), type: self.infoMode)
        self.collectionView.reloadData()
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
        self.switchListButton.action = #selector(ListImageTimelineViewController.openListsChooser)

        self.rtModeButton.target = self
        self.rtModeButton.action = #selector(ListImageTimelineViewController.toggleRTMode)
        self.rtMode = ConfigService.sharedInstance.selectImageViewModeType(TwitterManager.getUserID())
        self.rtModeButton.tintColor = self.rtMode == .IncludeRT ? UIColor.whiteColor() : UIColor.grayColor()
        self.infoModeButton.target = self
        self.infoModeButton.action = #selector(ListImageTimelineViewController.toggleInfoMode)
        self.infoMode = ConfigService.sharedInstance.selectInfoModeType(TwitterManager.getUserID())
        self.infoModeButton.tintColor = self.infoMode ? UIColor.whiteColor() : UIColor.grayColor()
    }

    func goBlack() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func viewDidAppear(animated: Bool) {
        guard let list = ListService.sharedInstance.selectHomeList() else {
            goBlack()
            return
        }
        self.bgViewHeight = 150
        if !list.isTimelineTabEnable() {
            self.setupTweets([])
            presentViewController(AlertManager.sharedInstantce.listMemberLimit(), animated: true, completion: nil)
            self.navigationController?.tabBarController?.selectedIndex = 0
            return
        }
        self.updateList()
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

    internal func updateList() {
        guard let list = ListService.sharedInstance.selectHomeList() else {
            self.openListsChooser()
            return
        }
        self.setupTabbarItemState()
        if let nowList = self.list where nowList.equalItem(list) {
            return
        }
        self.list = list
        self.navigationItem.title = list.name
        self.activityIndicator.startAnimating()
        self.setupTweets([MBTweet]())
        requestListTimeline(list)
    }

    override func viewWillDisappear(animated: Bool) {
        self.slideMenuController()?.removeLeftGestures()
    }

    override func viewWillAppear(animated: Bool) {
        self.slideMenuController()?.addLeftGestures()
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let isBouncing = (self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.bounds.size.height))
            && self.collectionView.dragging
        if isBouncing && !isUpdating {
            isUpdating = true
            activityIndicator.startAnimating()
            _ = Twitter.sharedInstance().requestListImageTweets(list, beforeTweet: tweets.last)
                .subscribeNext({ (tweets: [MBTweet]) in
                    self.setupTweets(self.tweets + tweets)
                })
        }
    }

    func setupTweets(tweets: [MBTweet]) {
        self.tweets = tweets
        self.imageCellInfos.removeAll()
        var urlDict = Dictionary<String, ImageCellInfo>()
        for tweet in tweets {
            for url in tweet.imageURLs {
                if let _ = urlDict[url] {
                } else {
                    let imageCellInfo = ImageCellInfo(imageURL: url, tweet: tweet)
                    imageCellInfos.append(imageCellInfo)
                    urlDict[url] = imageCellInfo
                }
                guard let info = urlDict[url] else {
                    return
                }
                info.counts += 1
            }
        }
        self.collectionView.reloadData()
        self.activityIndicator.stopAnimating()
        self.isUpdating = false
    }

    func didClickImageView(recognizer: UIGestureRecognizer) {
        if let cellView = recognizer.view as? ImageCell {
            // if let cellView = recognizer.view? as? UICollectionViewCell {
            let nextViewController = StoryBoardService.sharedInstance.photoViewController()
            nextViewController.viewerImgUrl = NSURL(string: cellView.imageView.sd_imageURL().absoluteString + ":orig")
            nextViewController.tweet = cellView.tweet
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }

}


extension ListImageTimelineViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCellWithReuseIdentifier("image-cell", forIndexPath: indexPath) as? ImageCell)!
        let info = self.imageCellInfos[indexPath.row]
        cell.setCellInfo(info)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ListImageTimelineViewController.didClickImageView(_:)))
        cell.addGestureRecognizer(recognizer)
        cell.setVisible(self.infoMode)
        return cell
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageCellInfos.count
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let w = self.view.frame.size.width / ListImageTimelineViewController.ColumnNum
        return CGSize(width: w, height: w)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }

}
