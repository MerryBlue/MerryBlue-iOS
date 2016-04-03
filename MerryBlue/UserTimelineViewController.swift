import UIKit
import TwitterKit
import FontAwesomeKit

class UserTimelineViewController: MBTimelineViewController {

    var delegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!

    convenience init() {
        guard let user = (UIApplication.sharedApplication().delegate as? AppDelegate)!.userViewUser else {
            self.init(dataSource: nil)
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
        guard let _ = delegate.userViewUser else {
            self.goBack()
            return
        }
        super.viewDidLoad()
        self.setupNavigationBar()
    }

    private func setupNavigationBar() {
        guard let _ = self.navigationController else {
            print("Error: no wrapperd navigation controller")
            return
        }

        self.navigationItem.title = self.title
        let backButtonItem = UIBarButtonItem(title: "戻る", style: .Plain, target: self, action: #selector(UserTimelineViewController.goBack))
        self.navigationItem.setHidesBackButton(false, animated: false)
        self.navigationItem.leftBarButtonItem = backButtonItem

        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(UserTimelineViewController.goBack))
        swipeLeftGesture.direction = .Right
        self.view.addGestureRecognizer(swipeLeftGesture)
    }

    func goBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
    }

}
