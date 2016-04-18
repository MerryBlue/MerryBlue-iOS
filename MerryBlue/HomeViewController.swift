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

    @IBOutlet weak var orderButton: UIBarButtonItem!
    @IBOutlet weak var cleanButton: UIBarButtonItem!
    @IBOutlet weak var switchListButton: UIBarButtonItem!

    var list: MBTwitterList!
    var users = [TwitterUser]()
    var filtered: Bool!
    // 初めは時間順，オーダーメソッドが呼ばれるので逆に設定
    var orderType: Int = 0

    var cacheCellHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        self.filtered = false
        self.setupTableView()
    }

    func checkLogin() {
        if !TwitterManager.isLogin() {
            self.presentViewController(StoryBoardService.sharedInstance.signInViewController(), animated: true, completion: nil)
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
        if list.disable() {
            self.activityIndicator.stopAnimating()
            presentViewController(AlertManager.sharedInstantce.listMemberLimit(), animated: true, completion: nil)
            return
        }
        self.activityIndicator.startAnimating()
        if let type = ConfigService.sharedInstance.selectOrderType(TwitterManager.getUserID()) {
            orderType = type
        } else {
            orderType = HomeViewOrderType.ReadCountOrder
        }
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
        if list.disable() {
            self.activityIndicator.stopAnimating()
            presentViewController(AlertManager.sharedInstantce.listMemberLimit(), animated: true, completion: nil)
            refreshControl.endRefreshing()
            return
        }
        _ = TwitterManager.requestMembers(list)
            .subscribeNext({ (users: [TwitterUser]) in
                self.setupListUsers(users)
        })
    }

    internal func setupListUsers(users: [TwitterUser]) {
        self.users = TwitterManager.sortUsersLastupdate(users)
        self.title = list.name
        self.setOrder()
        if self.activityIndicator.isAnimating() {
            self.activityIndicator.stopAnimating()
        }

        refreshControl.endRefreshing() // データが取れたら更新を終える（くるくる回るViewを消去）
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

        self.switchListButton.target = self
        self.switchListButton.action = #selector(HomeViewController.openListsChooser)
        self.orderButton.target = self
        self.orderButton.action = #selector(HomeViewController.changeOrder)
        self.cleanButton.target = self
        self.cleanButton.action = #selector(HomeViewController.cleanAll)

    }

    func cleanAll() {
        for user in users {
            user.updateReadedCount()
        }
        self.tableView.reloadData()
    }

    func changeOrder() {
        self.orderType = (self.orderType + 1) % 2
        ConfigService.sharedInstance.updateOrderType(TwitterManager.getUserID(), type: self.orderType)
        setOrder()
    }

    func setOrder() {
        switch orderType {
        case HomeViewOrderType.TimeOrder:
            self.users = TwitterManager.sortUsersLastupdate(users)
            self.orderButton.image = AssetSertvice.sharedInstance.iconSortByTime
        case HomeViewOrderType.ReadCountOrder:
            self.users = TwitterManager.sortUsersNewCountRev(users)
            self.orderButton.image = AssetSertvice.sharedInstance.iconSortByCount
        default:
            break
        }
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
        self.delegate.userViewNewCount = user.newCount()
        user.updateReadedCount()
        self.navigationController?.pushViewController(StoryBoardService.sharedInstance.userView(), animated: true)
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
        if let _ = self.list where self.list.equalItem(list) {
            return
        }
        self.activityIndicator.startAnimating()
        _ = TwitterManager.requestMembers(list)
            .subscribeNext({ (users: [TwitterUser]) in self.setupListUsers(users) })
        self.list = list
    }

}
