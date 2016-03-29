import UIKit
import TwitterKit
import RxSwift
import FontAwesomeKit

class LeftMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var delegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!

    @IBOutlet weak var profileBackgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    var user: TwitterUser!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!

    var twitterLists = [TwitterList]()
    var selectedIndex: NSIndexPath!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.setupTableView()
    }

    override func viewDidAppear(animated: Bool) {
        if user == nil {
            _ = TwitterManager.requestUserProfile(TwitterManager.getUserID())
                .subscribeNext({ (user: TwitterUser) in self.setProfiles(user)})
        }
        let lists = ListService.sharedInstance.adjustOptionalLists(ListService.sharedInstance.selectLists())

        if lists.isEmpty {
            self.activityIndicator.startAnimating()
            _ = TwitterManager.requestLists(TwitterManager.getUserID())
                .subscribeNext({ (lists: [TwitterList]) in self.setupTableView(lists) })
        } else {
            setupTableView(lists)
        }
        self.setupButtons()
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
        let loginView = storyboard.instantiateViewControllerWithIdentifier("login")
        self.presentViewController(loginView, animated: true, completion: nil)
    }

    private func setProfiles(user: TwitterUser) {
        nameLabel.text = user.name
        screenNameLabel.text = "@\(user.screenName)"
        do {
            let imageData = try NSData(contentsOfURL: NSURL(string: user.profileImageURL)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            let bannerImageData = try NSData(contentsOfURL: NSURL(string: user.profileBannerImageURL)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            self.profileImageView.image = UIImage(data: imageData)
            self.profileBackgroundImageView.image = UIImage(data: bannerImageData)
        } catch {
            print("Error: Image request invalid")
        }
    }

    internal func switchEditList() {
        self.tableView.setEditing(!self.tableView.editing, animated: true)
        if self.tableView.editing {
            // editButton.setImage(FAKIonIcons.iosGearIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26)), forState: .Normal)
            editButton.setTitle("完了", forState: .Normal)
            refreshControl.removeFromSuperview()
            self.slideMenuController()?.removeLeftGestures()
        } else {
            // editButton.setImage(nil, forState: .Normal)
            editButton.setTitle("", forState: .Normal)
            ListService.sharedInstance.updateLists(self.twitterLists)
            tableView.addSubview(refreshControl)
            self.slideMenuController()?.addLeftGestures()
        }
    }

    private func setupButtons() {
        editButton.setImage(FAKIonIcons.iosGearIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26)), forState: .Normal)
        editButton.setTitle("", forState: .Normal)
        editButton.addTarget(self, action: #selector(LeftMenuViewController.switchEditList), forControlEvents: .TouchUpInside)
        updateButton.setImage(FAKIonIcons.iosRefreshIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26)), forState: .Normal)
        updateButton.setTitle("", forState: .Normal)
        updateButton.addTarget(self, action: #selector(LeftMenuViewController.pullToRefresh), forControlEvents: .TouchUpInside)
        logoutButton.setImage(FAKIonIcons.logOutIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26)), forState: .Normal)
        logoutButton.setTitle("", forState: .Normal)
        logoutButton.addTarget(self, action: #selector(LeftMenuViewController.onClickLogoutButton(_:)), forControlEvents: .TouchUpInside)
    }

    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return twitterLists.count
    }

    //セルの内容を変更
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCellWithIdentifier("listInfoCell", forIndexPath: indexPath) as? ListInfoCell)!
        cell.setCell(twitterLists[indexPath.row])
        return cell
    }

    // 編集モードでセルの移動許可 & 削除拒否
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let si = sourceIndexPath.row
        let di = destinationIndexPath.row
        var swapRange: [Int]
        if si < di {
            swapRange = [Int](si..<di)
        } else {
            swapRange = (di..<si).reverse()
        }
        for i in swapRange {
            swap(&twitterLists[i], &twitterLists[i + 1])
        }
    }
    // func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
    // }

    internal func setupTableView(lists: [TwitterList]) {
        twitterLists = lists
        tableView.reloadData()

        if self.activityIndicator.isAnimating() {
            self.activityIndicator.stopAnimating()
        }

        if lists.isEmpty {
            let ac = UIAlertController(
                title: "リストが見つかりませんでした",
                message: "このアカウントはリストを作成, フォローしていません",
                preferredStyle: UIAlertControllerStyle.Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
        ListService.sharedInstance.updateLists(lists)
        // self.fetchListUpdate(lists)
    }

    private func fetchListUpdate(lists: [TwitterList]) {

    }

    // Cell が選択された場合
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let list = self.twitterLists[indexPath.row]
        selectCell(indexPath)
        if list.enable() {
            ListService.sharedInstance.updateHomeList(list)

            self.slideMenuController()?.changeMainViewController(
                (self.slideMenuController()?.mainViewController)!,
                close: true)
        } else {
            // 選択不可アラート
            let ac = UIAlertController(
                title: "メンバー数制限",
                message: "メンバー数が多すぎます(\(TwitterList.memberNumActiveMaxLimit)人まで)",
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

    func pullToRefresh() {
        _ = TwitterManager.requestLists(TwitterManager.getUserID())
            .subscribeNext({ (lists: [TwitterList]) in
                self.setupTableView(ListService.sharedInstance.fetchList(lists))
            })
        refreshControl.endRefreshing()
    }

    internal func setSelectedCell() {
        guard let list = ListService.sharedInstance.selectHomeList() else {
            return
        }

        for i in 0..<tableView.numberOfRowsInSection(0) {
            if twitterLists[i].listID == list.listID {
                selectCell(NSIndexPath(forRow: i, inSection: 0))
                break
            }
        }
    }
}
