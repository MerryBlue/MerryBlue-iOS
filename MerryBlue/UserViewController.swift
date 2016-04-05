import TwitterKit

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var delegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

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
        self.activityIndicator.startAnimating()
        // _ = TwitterManager.requestMembers(list)
        //     .subscribeNext({ (users: [TwitterUser]) in self.setupListUsers(users) })
    }

    // ====== tableview methods ======

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
        // return tweets.count
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
