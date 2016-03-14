import Foundation
import TwitterKit


class ListChooseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView!
    var texts: Array<String> = []
    var selectedText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.texts.append("hoge")
        self.texts.append("fuga")
        setNavigationBar()
        setTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }
    
    //セルの内容を変更
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = texts[indexPath.row]
        return cell
    }
    
    private func setTableView() {
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
        selectedText = self.texts[indexPath.row]
        ConfigManager.setName(selectedText)
    }
    
    func onClickBackButton() {
        self.goBack()
    }
    
    func goBack() {
        print("back")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}