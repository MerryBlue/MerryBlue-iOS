import Foundation
import TwitterKit


class ListChooseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView!
    var tweetLists: Array<TwitterList> = []
    var selectedIndex: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
    }
    
    override func viewDidAppear(animated: Bool) {
        TwitterManager.getLists(self)
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
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = tweetLists[indexPath.row].name
        return cell
    }
    
    internal func setTableView(lists: [TwitterList]) {
        tweetLists = lists
        // Status Barの高さを取得する.
        let barHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        // Viewの高さと幅を取得する.
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight - barHeight))
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ListNames")
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // self.navigationController?.navigationBar.barTintColor = UIColor.blueColor()
        // self.navigationController?.navigationBar.alpha = 0.1
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem
        self.navigationItem.title = "リスト選択"
        let backButtonItem = UIBarButtonItem(title: "完了", style: .Plain, target: self, action: "onClickBackButton")
        self.navigationItem.setHidesBackButton(false, animated: false)
        // HACK
        // self.navigationItem.backBarButtonItem = backButtonItem
        self.navigationItem.leftBarButtonItem = backButtonItem
    }
    
    // Cell が選択された場合
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        let selectedListId = self.tweetLists[indexPath.row].id
        ConfigManager.setListId(selectedListId)
        selectCell(indexPath)
    }
    
    func selectCell(indexPath: NSIndexPath) {
        if let i = selectedIndex {
            if indexPath.row == selectedIndex.row {
                return
            }
            // 元のセルをノーマルに
            let cell = tableView.cellForRowAtIndexPath(i)
            cell?.setSelected(false, animated: false)
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.setSelected(true, animated: false)
        // cell?.setHighlighted(true, animated: false)
        cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        selectedIndex = indexPath
    }
    
    func onClickBackButton() {
        self.goBack()
    }
    
    func goBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    internal func setSelectedCell() {
        guard let liistId = ConfigManager.getListId() else {
            return
        }
        
        for i in 0..<tableView.numberOfRowsInSection(0) {
            if tweetLists[i].id == liistId {
                selectCell(NSIndexPath(forRow: i, inSection: 0))
                break
            }
        }
    }
}