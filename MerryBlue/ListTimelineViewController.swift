import UIKit
import TwitterKit
import FontAwesomeKit

class ListTimelineViewController: TWTRTimelineViewController {
    
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
            self.openListsChooser()
            return
        }
        let client = TWTRAPIClient()
        let dataSource = TWTRListTimelineDataSource(listID: list.id, APIClient: client)
        self.init(dataSource: dataSource)
        self.title = "ListTimeline"
        self.setNavigationBar()
        self.list = list
        // TwitterManager.getListUsers(listId)
    }
    
    private func setNavigationBar() {
        let iconImage = FAKIonIcons.iosListIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26))
        let switchListButton = UIBarButtonItem(image: iconImage, style: .Plain, target: self, action: #selector(ListTimelineViewController.onClickSwitchList))
        
        self.navigationController?.navigationBar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // self.navigationController?.navigationBar.barTintColor = UIColor.blueColor()
        // self.navigationController?.navigationBar.alpha = 0.1
        self.navigationController?.navigationBar.translucent = false
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
        if (self.list.id == list.id) {
            return
        }
        let client = TWTRAPIClient()
        let dataSource = TWTRListTimelineDataSource(listID: list.id, APIClient: client)
        self.dataSource = dataSource
        self.refresh()
        self.list = list
    }
}
