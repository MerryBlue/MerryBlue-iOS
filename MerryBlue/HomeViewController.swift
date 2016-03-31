import UIKit
import TwitterKit
import FontAwesomeKit

struct HomeViewOrderType {
    static let TimeOrder = 0
    static let ReadCountOrder = 1
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var refreshControl: UIRefreshControl!
    var orderButton: UIBarButtonItem!
    var cleanButton: UIBarButtonItem!

    var list: TwitterList!
    var users = [TwitterUser]()
    var filtered: Bool!
    // 初めは時間順，オーダーメソッドが呼ばれるので逆に設定
    var orderType = HomeViewOrderType.ReadCountOrder

    var cacheCellHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        self.filtered = false
        self.setupTableView()
    }

    func checkLogin() {
        if !TwitterManager.isLogin() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginView = storyboard.instantiateViewControllerWithIdentifier("login")
            self.presentViewController(loginView, animated: true, completion: nil)
        }
    }

    override func viewDidAppear(animated: Bool) {
        checkLogin()
        guard let list = ListService.sharedInstance.selectHomeList() else {
            self.openListsChooser()
            return
        }
        if self.list != nil && self.list.listID == list.listID {
            self.tableView.reloadData()
            return
        }
        self.list = list
        self.activityIndicator.startAnimating()
        orderType = HomeViewOrderType.ReadCountOrder
        _ = TwitterManager.requestMembers(list)
            .subscribeNext({ (users: [TwitterUser]) in self.setupListUsers(users) })
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...") // Loading中に表示する文字を決める
        refreshControl.addTarget(self, action: #selector(HomeViewController.pullToRefresh), forControlEvents:.ValueChanged)
        self.tableView.addSubview(refreshControl)
        cacheCellHeight = self.tableView.rowHeight
    }

    func pullToRefresh() {
        guard let _ = ListService.sharedInstance.selectHomeList() else {
            self.openListsChooser()
            return
        }
        _ = TwitterManager.requestMembers(list)
            .subscribeNext({ (users: [TwitterUser]) in
                self.orderType = (self.orderType + 1) % 2
                self.setupListUsers(users)
        })
        refreshControl.endRefreshing() // データが取れたら更新を終える（くるくる回るViewを消去）
    }

    internal func setupListUsers(users: [TwitterUser]) {
        self.users = TwitterManager.sortUsersLastupdate(users)
        self.title = list.name
        self.changeOrder()
        if self.activityIndicator.isAnimating() {
            self.activityIndicator.stopAnimating()
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = (tableView.dequeueReusableCellWithIdentifier("userStatusCell") as? UserStatusCell)!
        // let cell = (tableView.dequeueReusableCellWithIdentifier(IdentifilerService.sharedInstance.homeCellID(user.userID)) as? UserStatusCell)!
        cell.setCell(user)
        return cell
    }

    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = users[indexPath.row]
        user.updateReadedCount()
        self.openUserTimeline(user)
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if filtered! && !users[indexPath.row].hasNew() {
            cell.hidden = true
        } else {
            cell.hidden = false
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.cacheCellHeight!
    }

    private func setNavigationBar() {
        guard let _ = self.navigationController else {
            print("Error: no wrapperd navigation controller")
            return
        }

        let switchListButton = UIBarButtonItem(
            image:FAKIonIcons.iosListIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26)),
            style: .Plain, target: self, action: #selector(HomeViewController.openListsChooser))
        orderButton = UIBarButtonItem(
            image: AssetSertvice.sharedInstance.iconSortByTime,
            style: .Plain,
            target: self,
            action: #selector(HomeViewController.changeOrder))
        cleanButton = UIBarButtonItem(
            image: FAKIonIcons.androidDraftsIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26)),
            style: .Plain,
            target: self,
            action: #selector(HomeViewController.cleanAll))

        self.navigationItem.setRightBarButtonItems([orderButton, cleanButton], animated: true)
        self.navigationItem.setLeftBarButtonItem(switchListButton, animated: true)
    }

    func cleanAll() {
        for user in users {
            user.updateReadedCount()
        }
        self.tableView.reloadData()
    }

    func changeOrder() {
        switch orderType {
        case HomeViewOrderType.TimeOrder:
            self.users = TwitterManager.sortUsersNewCount(users)
            self.orderButton.image = AssetSertvice.sharedInstance.iconSortByCount
        case HomeViewOrderType.ReadCountOrder:
            self.users = TwitterManager.sortUsersLastupdate(users)
            self.orderButton.image = AssetSertvice.sharedInstance.iconSortByTime
        default:
            break
        }

        self.orderType = (self.orderType + 1) % 2
        self.tableView.reloadData()
    }

    func filterReaded() {
        self.filtered = !self.filtered
        self.tableView.reloadData()
    }

    func openListsChooser() {
        guard let slideMenu = self.slideMenuController() else {
            print("Error: HomeView hove not Slidebar")
            return
        }
        slideMenu.openLeft()
    }

    func openUserTimeline(user: TwitterUser) {
        self.delegate.userViewUser = user
        // let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userNavView = MBNavigationController(rootViewController: UserTimelineViewController())
        self.presentViewController(userNavView, animated: true, completion: nil)
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
        if let nowList = self.list where nowList.listID == list.listID {
            return
        }
        self.activityIndicator.startAnimating()
        orderType = HomeViewOrderType.TimeOrder
        _ = TwitterManager.requestMembers(list)
            .subscribeNext({ (users: [TwitterUser]) in self.setupListUsers(users) })
        self.list = list
    }

}
