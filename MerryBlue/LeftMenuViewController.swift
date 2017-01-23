import UIKit
import TwitterKit
import RxSwift

class LeftMenuViewController: UIViewController {

    var delegate = (UIApplication.shared.delegate as? AppDelegate)!

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
    var selectedIndex: IndexPath!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        if user == nil {
            _ = Twitter.sharedInstance().requestUserProfile(TwitterManager.getUserID())
                .subscribeNext({ (user: TwitterUser) in self.setProfiles(user)})
        }
        let lists = ListService.sharedInstance.adjustOptionalLists(ListService.sharedInstance.selectLists())

        if lists.isEmpty {
            self.activityIndicator.startAnimating()
            _ = Twitter.sharedInstance().requestLists(TwitterManager.getUserID())
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
        refreshControl.addTarget(self, action: #selector(LeftMenuViewController.pullToRefresh), for:.valueChanged)
        // self.tableView.allowsMultipleSelectionDuringEditing = true
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.addSubview(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    internal func onClickLogoutButton(_ sender: UIButton) {
        TwitterManager.logoutUser()
        self.present(StoryBoardService.sharedInstance.signInViewController(), animated: true, completion: nil)
    }

    fileprivate func setProfiles(_ user: TwitterUser) {
        nameLabel.text = user.name
        screenNameLabel.text = "@\(user.screenName)"

        self.profileImageView.sd_setImageWithURL(URL(string: user.profileImageURL), placeholderImage: AssetSertvice.sharedInstance.loadingImage)
        self.profileBackgroundImageView.layer.backgroundColor = UIColor.white.cgColor

        if let url = user.profileBannerImageURL, !url.isEmpty {
            self.profileBackgroundImageView.clipsToBounds = true
            self.profileBackgroundImageView.contentMode = .scaleAspectFill
            self.profileBackgroundImageView.sd_setImageWithURL(URL(string: user.profileBannerImageURL), placeholderImage: AssetSertvice.sharedInstance.loadingImage)
        } else {
            self.profileBackgroundImageView.image = nil
            self.profileBackgroundImageView.layer.backgroundColor = MBColor.Main.CGColor
        }
    }

    internal func switchEditList() {
        if self.tableView.isEditing {
            // editButton.setImage(nil, forState: .Normal)
            editButton.setTitle("", for: UIControlState())
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
            editButton.setTitle("完了", for: UIControlState())
        }
    }

    func syncVisibleCells() {
        for (i, list) in twitterLists.enumerated() {
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0))
            cell?.setSelected(list.visible, animated: false)
        }
    }

    fileprivate func setupButtons() {
        editButton.addTarget(self, action: #selector(LeftMenuViewController.switchEditList), for: .touchUpInside)
        updateButton.addTarget(self, action: #selector(LeftMenuViewController.pullToRefresh), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(LeftMenuViewController.onClickLogoutButton(_:)), for: .touchUpInside)
    }


    internal func setupTableView(_ lists: [MBTwitterList]) {
        twitterLists = lists
        tableView.reloadData()

        if self.activityIndicator.isAnimating {
            self.activityIndicator.stopAnimating()
        }

        if lists.isEmpty {
            presentViewController(AlertManager.sharedInstantce.listNotFound(), animated: true, completion: nil)
        }
        ListService.sharedInstance.updateLists(lists)
        // self.fetchListUpdate(lists)
    }

    func pullToRefresh() {
        if self.tableView.isEditing {
            // 編集中はリスト更新制限アラート
            presentViewController(AlertManager.sharedInstantce.listSyncDisable(), animated: true, completion: nil)
            return
        }
        _ = Twitter.sharedInstance().requestLists(TwitterManager.getUserID())
            .subscribeNext({ (lists: [MBTwitterList]) in
                self.setupTableView(ListService.sharedInstance.fetchList(lists))
            })
        refreshControl.endRefreshing()
    }

}

extension LeftMenuViewController: UITableViewDelegate {

}

extension LeftMenuViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let list = self.twitterLists[indexPath.row]
        // cell.setSelected(list.visible, animated: false)
        cell.setSelected(false, animated: false)
        cell.backgroundColor = UIColor.white
        cell.accessoryType = .none

        if tableView.isEditing && list.visible {
            cell.accessoryType = .checkmark
            cell.setSelected(true, animated: false)
        } else if let homeList = ListService.sharedInstance.selectHomeList(), homeList.equalItem(list) {
            cell.backgroundColor = MBColor.LightSub
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return twitterLists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = twitterLists[indexPath.row]
        let cell = (tableView.dequeueReusableCell(withIdentifier: "listInfoCell", for: indexPath) as? ListInfoCell)!
        // let cell = (tableView.dequeueReusableCellWithIdentifier(IdentifilerService.sharedInstance.listCellID(list.listID), forIndexPath: indexPath) as? ListInfoCell)!
        cell.setCell(list)
        return cell
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let si = sourceIndexPath.row
        let di = destinationIndexPath.row
        var swapRange: [Int]
        if si < di {
            swapRange = [Int](si..<di)
        } else {
            swapRange = (di..<si).reversed()
        }
        for i in swapRange {
            swap(&twitterLists[i], &twitterLists[i + 1])
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let list = twitterLists[indexPath.row]
        list.visible = false
    }

    func tableView(_ table: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = self.twitterLists[indexPath.row]
        if self.tableView.isEditing {
            list.visible = true
            return
        }
        // selectCell(indexPath)
        ListService.sharedInstance.updateHomeList(list)

        self.slideMenuController()?.changeMainViewController(
            (self.slideMenuController()?.mainViewController)!,
            close: true)
    }

}
