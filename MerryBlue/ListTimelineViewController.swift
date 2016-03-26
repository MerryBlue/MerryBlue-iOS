import UIKit
import TwitterKit
import FontAwesomeKit

class ListTimelineViewController: MBTimelineViewController {
    
    var list: TwitterList!
    convenience init() {
        guard let list: TwitterList = ListService.sharedInstance.selectHomeList() else {
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
        let client = TWTRAPIClient()
        let dataSource = TWTRListTimelineDataSource(listID: list.id, APIClient: client)
        self.init(dataSource: dataSource)
        self.showTweetActions = true
        self.title = "ListTimeline"
        self.list = list
        // TwitterManager.getListUsers(listId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        guard let navCon = self.navigationController else {
            print("Error: no wrapperd navigation controller")
            return
        }
        
        let iconImage = FAKIonIcons.iosListIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26))
        let switchListButton = UIBarButtonItem(image: iconImage, style: .Plain, target: self, action: #selector(ListTimelineViewController.onClickSwitchList))
        
        navCon.navigationBar
        navCon.setNavigationBarHidden(false, animated: false)
        navCon.navigationBar.barTintColor = UIColor.blueColor()
        navCon.navigationBar.alpha = 0.1
        navCon.navigationBar.translucent = false
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
        guard let list: TwitterList = ListService.sharedInstance.selectHomeList() else {
            self.openListsChooser()
            return
        }
        if let nowList = self.list where nowList.id == list.id {
            return
        }
        let client = TWTRAPIClient()
        let dataSource = TWTRListTimelineDataSource(listID: list.id, APIClient: client)
        self.dataSource = dataSource
        self.refresh()
        self.list = list
    }
}
