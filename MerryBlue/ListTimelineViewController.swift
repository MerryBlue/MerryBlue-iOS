import UIKit
import TwitterKit

class ListTimelineViewController: UIViewController {
    var delegate = (UIApplication.shared.delegate as? AppDelegate)!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var switchListButton: UIBarButtonItem!

    var refreshControl: UIRefreshControl!

    var tweets: [MBTweet]!

    var cacheHeights = [CGFloat]()
    var list: MBTwitterList!

    var isUpdating = true
    var bgViewHeight: CGFloat!
    var isNoTweet = false

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
        refreshControl.addTarget(self, action: #selector(ListTimelineViewController.pullToRefresh), for:.valueChanged)
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
                .subscribe(onNext: { (tweets: [MBTweet]) in
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

    fileprivate func setNavigationBar() {
        guard let _ = ListService.sharedInstance.selectHomeList() else {
            print("Error: no wrapperd navigation controller")
            return
        }
        self.switchListButton.target = self
        self.switchListButton.action = #selector(ListTimelineViewController.openListsChooser)
    }

    func goBlack() {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        guard let _ = ListService.sharedInstance.selectHomeList() else {
            goBlack()
            return
        }
        self.bgViewHeight = 150
        self.updateList()
    }

    func setupTabbarItemState() {
        guard let items: [UITabBarItem] = self.tabBarController!.tabBar.items,
            let list = ListService.sharedInstance.selectHomeList(), items.count == 2 else { return }
        items[0].isEnabled = list.isHomeTabEnable()
        items[1].isEnabled = list.isTimelineTabEnable()
    }

    func didClickImageView(_ recognizer: UIGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            let nextViewController = StoryBoardService.sharedInstance.photoViewController()
            nextViewController.viewerImgUrl = URL(string: imageView.sd_imageURL().absoluteString + ":orig")
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }

    internal func updateList() {
        guard let list = ListService.sharedInstance.selectHomeList() else {
            self.openListsChooser()
            return
        }
        if let nowList = self.list, nowList.equalItem(list) {
            return
        }
        self.list = list
        self.setupTabbarItemState()
        self.navigationItem.title = list.name
        self.activityIndicator.startAnimating()
        self.tableView.contentOffset = CGPoint(x: 0, y: -self.tableView.contentInset.top)
        self.requestTimeline()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.slideMenuController()?.removeLeftGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.slideMenuController()?.addLeftGestures()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isBouncing = (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) && self.tableView.isDragging
        if isBouncing && !isUpdating && self.list.isTimelineTabEnable() {
            isUpdating = true
            activityIndicator.startAnimating()
            _ = Twitter.sharedInstance().requestListTimelineNext(self.list, beforeTweet: tweets.last!)
                .subscribe(onNext: { (tweets: [MBTweet]) in
                    self.setupTweets(self.tweets + tweets)
                })
        }
    }

    func setupTweets(_ tweets: [MBTweet]) {
        self.tweets = tweets
        if self.tweets.count == 0 {
            self.tweets.append(MBTweet())
            self.isNoTweet = true
        }
        self.tableView.reloadData()
        self.activityIndicator.stopAnimating()
        self.isUpdating = false
    }

}

extension ListTimelineViewController: UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tws = tweets else { return 0 }
        return tws.count
    }

}

extension ListTimelineViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "tweet", for: indexPath) as? UserTweetCell)!
        let tweet = tweets[indexPath.row]
        if !self.list.isTimelineTabEnable() {
            cell.setInfoCell(self.list, message: "このリストは特別なリストなためタイムラインを取得できません")
            return cell
        } else if isNoTweet {
            cell.setInfoCell(self.list, message: "該当ツイートがありません")
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

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tweet = tweets[indexPath.row]
        self.delegate.showTweet = tweet
        self.navigationController?.pushViewController(StoryBoardService.sharedInstance.showTweetView(), animated: true)
    }

}
