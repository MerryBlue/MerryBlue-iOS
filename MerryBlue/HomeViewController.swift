import UIKit
import TwitterKit

enum HomeViewOrderType: Int {
    case timeOrder
    case readCountOrder
    case readCountOrderRev

    case dummy

    func next() -> HomeViewOrderType {
        return HomeViewOrderType(rawValue: (self.rawValue + HomeViewOrderType.dummy.rawValue + 1) % HomeViewOrderType.dummy.rawValue)!
    }
}

class HomeViewController: UIViewController {

    var delegate = (UIApplication.shared.delegate as? AppDelegate)!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var refreshControl: UIRefreshControl!

    @IBOutlet weak var orderButton: UIBarButtonItem!
    @IBOutlet weak var cleanButton: UIBarButtonItem!
    @IBOutlet weak var switchListButton: UIBarButtonItem!

    var list: MBTwitterList!
    var users = [TwitterUser]()
    // 初めは時間順，オーダーメソッドが呼ばれるので逆に設定
    var orderType = HomeViewOrderType.timeOrder

    var cacheCellHeight: CGFloat!
    var listEnable = true
    var isNoUser = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        self.setupTableView()
        self.setupTabbarItemState()
    }

    func checkLogin() {
        if !TwitterManager.isLogin() {
            self.present(StoryBoardService.sharedInstance.signInViewController(), animated: true, completion: nil)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        self.checkLogin()
        guard let _ = ListService.sharedInstance.selectHomeList() else {
            self.openListsChooser()
            return
        }
        orderType = ConfigService.sharedInstance.selectOrderType(TwitterManager.getUserID())
        self.updateList()
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...") // Loading中に表示する文字を決める
        refreshControl.addTarget(self, action: #selector(HomeViewController.pullToRefresh), for:.valueChanged)
        self.tableView.addSubview(refreshControl)
        cacheCellHeight = self.tableView.rowHeight
    }

    func pullToRefresh() {
        guard let _ = ListService.sharedInstance.selectHomeList() else {
            self.openListsChooser()
            return
        }
        _ = Twitter.sharedInstance().requestMembers(list)
            .subscribeNext({ (users: [TwitterUser]) in
                self.setupListUsers(users)
        })
    }

    internal func setupListUsers(_ users: [TwitterUser]) {
        self.users = TwitterManager.sortUsersLastupdate(users)
        if self.users.count == 0 {
            self.users.append(TwitterUser())
            self.isNoUser = true
        }
        if !self.listEnable {
            self.users.insert(self.users.first!, at: 0)
        }
        self.setOrder()
        if self.activityIndicator.isAnimating {
            self.activityIndicator.stopAnimating()
        }
        refreshControl.endRefreshing() // データが取れたら更新を終える（くるくる回るViewを消去）
    }

    fileprivate func setNavigationBar() {
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
        self.orderType = self.orderType.next()
        ConfigService.sharedInstance.updateOrderType(TwitterManager.getUserID(), type: self.orderType)
        setOrder()
    }

    func setOrder() {
        switch orderType {
        case HomeViewOrderType.timeOrder:
            self.users = TwitterManager.sortUsersLastupdate(users)
            self.orderButton.image = AssetSertvice.sharedInstance.iconSortByTime
        case HomeViewOrderType.readCountOrder:
            self.users = TwitterManager.sortUsersNewCount(users)
            self.orderButton.image = AssetSertvice.sharedInstance.iconSortByCount
        case HomeViewOrderType.readCountOrderRev:
            self.users = TwitterManager.sortUsersNewCountRev(users)
            self.orderButton.image = AssetSertvice.sharedInstance.iconSortByCountRev
        default:
            break
        }
        self.tableView.contentOffset = CGPoint(x: 0, y: -self.tableView.contentInset.top)
        self.tableView.reloadData()
    }

    func openListsChooser() {
        guard let slideMenu = self.slideMenuController() else {
            print("Error: HomeView hove not Slidebar")
            return
        }
        slideMenu.openLeft()
    }

    func openUserTimeline(_ user: TwitterUser) {
        self.delegate.userViewUser = user
        self.delegate.userViewNewCount = user.newCount()
        user.updateReadedCount()
        self.tableView.reloadData()
        self.navigationController?.pushViewController(StoryBoardService.sharedInstance.userView(), animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.slideMenuController()?.removeLeftGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.slideMenuController()?.addLeftGestures()
    }

    func setupTabbarItemState() {
        guard let items: [UITabBarItem] = self.tabBarController!.tabBar.items,
            let list = ListService.sharedInstance.selectHomeList(), items.count == 2 else { return }

        items[0].isEnabled = list.isHomeTabEnable()
        items[1].isEnabled = list.isTimelineTabEnable()
    }

    internal func updateList() {
        guard let list = ListService.sharedInstance.selectHomeList() else {
            self.openListsChooser()
            return
        }
        self.setupTabbarItemState()
        if let nowList = self.list, nowList.equalItem(list) {
            return
        }
        self.list = list
        self.navigationItem.title = list.name
        self.activityIndicator.startAnimating()
        _ = Twitter.sharedInstance().requestMembers(list)
            .subscribeNext({ (users: [TwitterUser]) in self.setupListUsers(users) })
        self.listEnable = list.isHomeTabEnable()
    }

}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ table: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        self.openUserTimeline(user)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cacheCellHeight!
    }

}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "userStatusCell") as? UserStatusCell)!
        if indexPath.row == 0 && !self.listEnable {
            let message = "このリストはユーザ数が多いため最近追加されたユーザのみ表示されます．\(list.memberCount) -> \(MBTwitterList.memberNumActiveMaxLimit)"
            cell.setInfoCell(message)
            return cell
        } else if self.isNoUser {
            cell.setInfoCell("該当ユーザがいません")
            return cell
        }
        let user = users[indexPath.row]
        // let cell = (tableView.dequeueReusableCellWithIdentifier(IdentifilerService.sharedInstance.homeCellID(user.userID)) as? UserStatusCell)!
        cell.setCell(user)
        return cell
    }

}
