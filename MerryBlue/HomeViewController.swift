import UIKit
import TwitterKit
import FontAwesomeKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var refreshControl: UIRefreshControl!
    var filterButton: UIBarButtonItem!
    var cleanButton: UIBarButtonItem!
    
    var list: TwitterList!
    var users = [TwitterUser]()
    var filtered: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.setNavigationBar()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...") // Loading中に表示する文字を決める
        refreshControl.addTarget(self, action: "pullToRefresh", forControlEvents:.ValueChanged)
        self.filtered = false
        
        self.tableView.addSubview(refreshControl)
    }
    
    func pullToRefresh(){
        _ = TwitterManager.requestListMembers(list.id).subscribeNext({ (users) -> Void in self.setupListUsers(users) })
        refreshControl.endRefreshing() // データが取れたら更新を終える（くるくる回るViewを消去）
    }
    
    override func viewDidAppear(animated: Bool) {
        guard let list: TwitterList = ListService.sharedInstance.selectHomeList() else {
            self.openListsChooser()
            return
        }
        if self.list != nil && self.list.id == list.id {
            self.tableView.reloadData()
            return
        }
        self.list = list
        self.activityIndicator.startAnimating()
        _ = TwitterManager.requestListMembers(list.id).subscribeNext({ (users) -> Void in self.setupListUsers(users) })
    }
    
    internal func setupListUsers(users: [TwitterUser]) {
        self.users = users
        self.title = list.name
        self.tableView.reloadData()
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
        let cell: UserStatusCell = tableView.dequeueReusableCellWithIdentifier("userStatusCell", forIndexPath: indexPath) as! UserStatusCell
        cell.setCell(users[indexPath.row])
        return cell
    }
    
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = users[indexPath.row]
        user.updateReadedCount()
        self.openUserTimeline(user)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (filtered! && !users[indexPath.row].hasNew()) {
            cell.hidden = true
        } else {
            cell.hidden = false
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (filtered! && !users[indexPath.row].hasNew()) {
            return 0
        }
        return self.tableView.rowHeight
    }
    
    private func setNavigationBar() {
        let switchListButton = UIBarButtonItem(
            image:FAKIonIcons.iosListIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26)),
            style: .Plain, target: self, action: "openListsChooser")
        filterButton = UIBarButtonItem(
            image: FAKIonIcons.funnelIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26)),
            style: .Plain,
            target: self,
            action: "filterReaded")
        cleanButton = UIBarButtonItem(
            image: FAKIonIcons.androidDraftsIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26)),
            style: .Plain,
            target: self,
            action: "cleanAll")
        
        self.navigationController?.navigationBar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // self.navigationController?.navigationBar.barTintColor = UIColor.blueColor()
        // self.navigationController?.navigationBar.alpha = 0.1
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem
        self.navigationItem.title = "HomeBoard"
        self.navigationItem.setRightBarButtonItem(switchListButton, animated: true)
        self.navigationItem.setLeftBarButtonItems([filterButton, cleanButton], animated: true)
    }
    
    func cleanAll() {
        for user in users {
            user.updateReadedCount()
        }
        self.tableView.reloadData()
    }
    
    func filterReaded() {
        self.filtered = !self.filtered
        self.tableView.reloadData()
    }
    
    func openListsChooser() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("lists")
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func openUserTimeline(user: TwitterUser) {
        self.delegate.userViewUser = user
        let vc = UINavigationController(rootViewController: UserTimelineViewController())
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        guard let list: TwitterList = ListService.sharedInstance.selectHomeList() else {
            self.openListsChooser()
            return
        }
        if (self.list.id == list.id) {
            return
        }
        self.activityIndicator.startAnimating()
        _ = TwitterManager.requestListMembers(list.id).subscribeNext({ (users) -> Void in self.setupListUsers(users) })
        self.list = list
    }
}