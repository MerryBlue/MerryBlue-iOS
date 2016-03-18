import Foundation
import TwitterKit


class ListChooseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var backButtonItem: UIBarButtonItem!
    var tweetLists: Array<TwitterList> = []
    var selectedIndex: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
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
        let cell: ListInfoCell = tableView.dequeueReusableCellWithIdentifier("listInfoCell", forIndexPath: indexPath) as! ListInfoCell
        cell.setCell(tweetLists[indexPath.row])
        return cell
    }
    
    internal func setTableView(lists: [TwitterList]) {
        tweetLists = lists
        tableView.reloadData()
    }
    
    private func setNavigationBar() {
        backButtonItem.action = "goBack"
        // backButtonItem.addTarget(self, action: "tapBarButtonItem:", forControlEvents:UIControlEvents.TouchUpInside)
    }
    
    // Cell が選択された場合
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        let selectedListId = self.tweetLists[indexPath.row].id
        ConfigManager.setListId(selectedListId)
        selectCell(indexPath)
        goBack()
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