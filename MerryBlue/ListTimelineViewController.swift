import UIKit
import TwitterKit
import FontAwesomeKit

class ListTimelineViewController: MBTimelineViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var list: TwitterList!
    convenience init() {
        guard let list = ListService.sharedInstance.selectHomeList() else {
            // TWTRUserTimelineDataSource(screenName: nil, userID: TwitterManager.getUserID(), APIClient: TwitterManager.getClient()
            // self.init(dataSource: )
            self.init(dataSource: TWTRUserTimelineDataSource(
                screenName: nil,
                userID: TwitterManager.getUserID(),
                APIClient: TwitterManager.getClient(),
                maxTweetsPerRequest: 50,
                includeReplies: false,
                includeRetweets: false
                ))
            // self.openListsChooser()
            return
        }
        let dataSource = TWTRListTimelineDataSource(listID: list.listID, APIClient: TwitterManager.getClient())
        self.init(dataSource: dataSource)
        self.showTweetActions = true
        self.title = "ListTimeline"
        self.list = list
        // TwitterManager.getListUsers(listId)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        self.setupNavigationBar()
    }

    private func setupNavigationBar() {
        guard let _ = self.navigationController else {
            print("Error: no wrapperd navigation controller")
            return
        }

        let iconImage = FAKIonIcons.iosListIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26))
        let switchListButton = UIBarButtonItem(image: iconImage, style: .Plain, target: self, action: #selector(ListTimelineViewController.onClickSwitchList))
        self.navigationItem
        self.navigationItem.title = "ListTimeline"
        self.navigationItem.setLeftBarButtonItem(switchListButton, animated: true)
    }

    func onClickSwitchList() {
        self.openListsChooser()
    }

    func openListsChooser() {
        guard let slideMenu = self.slideMenuController() else {
            print("Error: HomeView hove not Slidebar")
            return
        }
        slideMenu.openLeft()
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        guard let _ = TwitterManager.getUserID() else {
            return
        }
        guard let list = ListService.sharedInstance.selectHomeList() else {
            self.openListsChooser()
            return
        }
        if let nowList = self.list where nowList.listID == list.listID {
            return
        }
        let client = TWTRAPIClient()
        let dataSource = TWTRListTimelineDataSource(listID: list.listID, APIClient: client)
        self.dataSource = dataSource
        self.refresh()
        self.list = list
        if self.list.isSpecialType() {
            presentViewController(AlertManager.sharedInstantce.disableTabSpecialTab(), animated: true, completion: nil)
        }
    }
}
