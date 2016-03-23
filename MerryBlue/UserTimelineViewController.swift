import UIKit
import TwitterKit
import FontAwesomeKit

class UserTimelineViewController: TWTRTimelineViewController {
    
    var delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    convenience init() {
        guard let user = (UIApplication.sharedApplication().delegate as! AppDelegate).userViewUser else {
            self.init()
            self.goBack()
            return
        }
        let client = TwitterManager.getClient()
        
        let dataSource = TWTRUserTimelineDataSource(
            screenName:nil,
            userID: user.userID,
            APIClient: client,
            maxTweetsPerRequest: 0,
            includeReplies: true,
            includeRetweets: true
        )
        self.init(dataSource: dataSource)
        self.showTweetActions = true
        self.title = "@\(user.screenName)"

        user.updateReadedCount()
        // TwitterManager.getListUsers(listId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        guard let _ = self.navigationController else {
            print("Error: no wrapperd navigation controller")
            return
        }
        
        self.navigationItem.title = self.title
        let backButtonItem = UIBarButtonItem(title: "戻る", style: .Plain, target: self, action: #selector(UserTimelineViewController.onClickBackButton))
        self.navigationItem.setHidesBackButton(false, animated: false)
        self.navigationItem.leftBarButtonItem = backButtonItem
    }
    
    func onClickBackButton() {
        self.goBack()
    }
    
    func goBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
    }
}