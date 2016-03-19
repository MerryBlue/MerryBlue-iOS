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
        self.title = "@\(user.screenName)"
        self.setNavigationBar()

        user.updateReadedCount()
        // TwitterManager.getListUsers(listId)
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // self.navigationController?.navigationBar.barTintColor = UIColor.blueColor()
        // self.navigationController?.navigationBar.alpha = 0.1
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem
        self.navigationItem.title = self.title
        let backButtonItem = UIBarButtonItem(title: "戻る", style: .Plain, target: self, action: "onClickBackButton")
        self.navigationItem.setHidesBackButton(false, animated: false)
        // HACK
        // self.navigationItem.backBarButtonItem = backButtonItem
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