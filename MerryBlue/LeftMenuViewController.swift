import UIKit
import TwitterKit
import RxSwift

class LeftMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var profileBackgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    var user: TwitterUser!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!

    var tweetLists: Array<TwitterList> = []
    var selectedIndex: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.setupTableView()
    }
    
    override func viewDidAppear(animated: Bool) {
        if user == nil {
            _ = TwitterManager.requestUserProfile(TwitterManager.getUserID()).subscribeNext({ (user) -> Void in self.setProfiles(user)})
        }
        let lists = ListService.sharedInstance.selectLists()
        if lists.isEmpty {
            self.activityIndicator.startAnimating()
            _ = TwitterManager.requestLists(TwitterManager.getUserID()).subscribeNext({ (lists) -> Void in self.setupTableView(lists) })
        } else {
            setupTableView(lists)
        }
        self.setLogoutButton()
    }
    
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...") // Loading中に表示する文字を決める
        refreshControl.addTarget(self, action: #selector(LeftMenuViewController.pullToRefresh), forControlEvents:.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    internal func onClickLogoutButton(sender: UIButton) {
        TwitterManager.logoutUser()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateInitialViewController()
        self.presentViewController(initialViewController!, animated: true, completion: nil)
    }
    
    private func setProfiles(user: TwitterUser) {
        nameLabel.text = user.name
        screenNameLabel.text = "@\(user.screenName)"
        do {
            let imageData: NSData = try NSData(contentsOfURL: NSURL(string: user.profileImageURL)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            let bgImageData: NSData = try NSData(contentsOfURL: NSURL(string: user.profileBackgroundImageURL)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            self.profileImageView.image = UIImage(data: imageData)
            self.profileBackgroundImageView.image = UIImage(data: bgImageData)
        } catch {
            print("Error: Image request invalid")
        }
    }
    
    private func setLogoutButton() {
        logoutButton.addTarget(self, action: #selector(LeftMenuViewController.onClickLogoutButton(_:)), forControlEvents: .TouchUpInside)
    }
    
    
    
    
    
    
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetLists.count
    }
    
    //セルの内容を変更
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ListInfoCell = tableView.dequeueReusableCellWithIdentifier("listInfoCell", forIndexPath: indexPath) as! ListInfoCell
        cell.setCell(tweetLists[indexPath.row])
        return cell
    }
    
    internal func setupTableView(lists: [TwitterList]) {
        tweetLists = lists
        tableView.reloadData()
        
        if self.activityIndicator.isAnimating() {
            self.activityIndicator.stopAnimating()
        }
        
        if lists.isEmpty {
            let ac: UIAlertController = UIAlertController(
                title: "リストが見つかりませんでした",
                message: "このアカウントはリストを作成, フォローしていません",
                preferredStyle: UIAlertControllerStyle.Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
        // self.fetchListUpdate(lists)
    }
    
    private func fetchListUpdate(lists: [TwitterList]) {
        
    }
    
    // Cell が選択された場合
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        let list = self.tweetLists[indexPath.row]
        selectCell(indexPath)
        if list.enable() {
            ListService.sharedInstance.updateHomeList(list)
            self.slideMenuController()?.closeLeft()
        } else {
            // 選択不可アラート
            let ac: UIAlertController = UIAlertController(
                title: "メンバー数制限",
                message: "メンバー数が多すぎます(50人まで)",
                preferredStyle: UIAlertControllerStyle.Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    func selectCell(indexPath: NSIndexPath) {
        if let i = selectedIndex {
            if indexPath.row == selectedIndex.row {
                return
            }
            // 元のセルをノーマルに
            let cell = tableView.cellForRowAtIndexPath(i)
            cell?.setHighlighted(false, animated: false)
            cell?.setSelected(false, animated: false)
            // cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.setSelected(true, animated: false)
        cell?.setHighlighted(true, animated: false)
        // cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        selectedIndex = indexPath
    }
    
    func pullToRefresh(){
        _ = TwitterManager.requestLists(TwitterManager.getUserID()).subscribeNext({ (lists) -> Void in self.setupTableView(lists) })
        refreshControl.endRefreshing()
    }
    
    internal func setSelectedCell() {
        guard let list: TwitterList = ListService.sharedInstance.selectHomeList() else {
            return
        }
        
        for i in 0..<tableView.numberOfRowsInSection(0) {
            if tweetLists[i].id == list.id {
                selectCell(NSIndexPath(forRow: i, inSection: 0))
                break
            }
        }
    }
}