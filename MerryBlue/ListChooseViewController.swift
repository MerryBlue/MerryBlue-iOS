import Foundation
import TwitterKit


class ListChooseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var backButtonItem: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!

    var tweetLists: Array<TwitterList> = []
    var selectedIndex: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...") // Loading中に表示する文字を決める
        refreshControl.addTarget(self, action: "pullToRefresh", forControlEvents:.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        setNavigationBar()
    }
    
    override func viewDidAppear(animated: Bool) {
        let lists = ListService.sharedInstance.selectLists()
        if lists.isEmpty {
            self.activityIndicator.startAnimating()
            TwitterManager.getLists(self)
        } else {
            setupTableView(lists)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    private func setNavigationBar() {
        backButtonItem.action = "goBack"
        // backButtonItem.addTarget(self, action: "tapBarButtonItem:", forControlEvents:UIControlEvents.TouchUpInside)
    }
    
    // Cell が選択された場合
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        let list = self.tweetLists[indexPath.row]
        selectCell(indexPath)
        if list.enable() {
            ListService.sharedInstance.updateHomeList(list)
            goBack()
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
        TwitterManager.getLists(self)
        refreshControl.endRefreshing()
    }
    
    func onClickBackButton() {
        self.goBack()
    }
    
    func goBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
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