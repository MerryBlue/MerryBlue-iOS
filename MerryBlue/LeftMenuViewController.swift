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

    var twitterLists = [MBTwitterList]()
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
                .subscribeNext({ (lists: [MBTwitterList]) in self.setupTableView(lists) })
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
        // self.tableView.allowsMultipleSelectionDuringEditing = true
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.addSubview(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    internal func onClickLogoutButton(sender: UIButton) {
        TwitterManager.logoutUser()
        self.presentViewController(StoryBoardService.sharedInstance.signInViewController(), animated: true, completion: nil)
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
        if self.tableView.editing {
            // editButton.setImage(nil, forState: .Normal)
            editButton.setTitle("", forState: .Normal)
            ListService.sharedInstance.updateLists(self.twitterLists)

            tableView.addSubview(refreshControl)
            self.slideMenuController()?.addLeftGestures()
            self.tableView.setEditing(false, animated: true)
            self.setupTableView(self.twitterLists)
        } else {
            self.tableView.setEditing(true, animated: true)
            // syncVisibleCells()
            refreshControl.removeFromSuperview()
            self.slideMenuController()?.removeLeftGestures()
            editButton.setTitle("完了", forState: .Normal)
        }
    }

    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let list = self.twitterLists[indexPath.row]
        // cell.setSelected(list.visible, animated: false)
        if tableView.editing && list.visible {
            cell.accessoryType = .Checkmark
            cell.setSelected(true, animated: false)
        } else {
            cell.accessoryType = .None
            cell.setSelected(false, animated: false)
        }
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    }

    func syncVisibleCells() {
        for (i, list) in twitterLists.enumerate() {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))
            cell?.setSelected(list.visible, animated: false)
        }
    }

    private func setupButtons() {
        editButton.addTarget(self, action: #selector(LeftMenuViewController.switchEditList), forControlEvents: .TouchUpInside)
        updateButton.addTarget(self, action: #selector(LeftMenuViewController.pullToRefresh), forControlEvents: .TouchUpInside)
        logoutButton.addTarget(self, action: #selector(LeftMenuViewController.onClickLogoutButton(_:)), forControlEvents: .TouchUpInside)
    }

    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return twitterLists.count
    }

    //セルの内容を変更
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let list = twitterLists[indexPath.row]
        let cell = (tableView.dequeueReusableCellWithIdentifier("listInfoCell", forIndexPath: indexPath) as? ListInfoCell)!
        // let cell = (tableView.dequeueReusableCellWithIdentifier(IdentifilerService.sharedInstance.listCellID(list.listID), forIndexPath: indexPath) as? ListInfoCell)!
        cell.setCell(list)
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

    internal func setupTableView(lists: [MBTwitterList]) {
        twitterLists = lists
        tableView.reloadData()

        if self.activityIndicator.isAnimating() {
            self.activityIndicator.stopAnimating()
        }

        if lists.isEmpty {
            presentViewController(AlertManager.sharedInstantce.listNotFound(), animated: true, completion: nil)
        }
        ListService.sharedInstance.updateLists(lists)
        // self.fetchListUpdate(lists)
    }

    private func fetchListUpdate(lists: [MBTwitterList]) {

    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let list = twitterLists[indexPath.row]
        list.visible = false
    }

    // Cell が選択された場合
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let list = self.twitterLists[indexPath.row]
        if self.tableView.editing {
            list.visible = true
            return
        }
        // selectCell(indexPath)
        ListService.sharedInstance.updateHomeList(list)

        self.slideMenuController()?.changeMainViewController(
            (self.slideMenuController()?.mainViewController)!,
            close: true)
    }

    func pullToRefresh() {
        if self.tableView.editing {
            // 編集中はリスト更新制限アラート
            presentViewController(AlertManager.sharedInstantce.listSyncDisable(), animated: true, completion: nil)
            return
        }
        _ = TwitterManager.requestLists(TwitterManager.getUserID())
            .subscribeNext({ (lists: [MBTwitterList]) in
                self.setupTableView(ListService.sharedInstance.fetchList(lists))
            })
        refreshControl.endRefreshing()
    }

}
