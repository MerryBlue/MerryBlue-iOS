import UIKit
import TwitterKit
import FontAwesomeKit

class ListTimelineViewController: TWTRTimelineViewController {
    
    var list: TwitterList!
    convenience init() {
        guard let list: TwitterList = ListService.sharedInstance.selectHomeList(0) else {
            self.init()
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
        let switchListButton = UIBarButtonItem(image: iconImage, style: .Plain, target: self, action: "onClickSwitchList")
        
        self.navigationController?.navigationBar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // self.navigationController?.navigationBar.barTintColor = UIColor.blueColor()
        // self.navigationController?.navigationBar.alpha = 0.1
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem
        self.navigationItem.title = "ListTimeline"
        self.navigationItem.setRightBarButtonItem(switchListButton, animated: true)
    }
    
    func onClickSwitchList() {
        self.openListsChooser()
    }
    
    func openListsChooser() {
        let vc = UINavigationController(rootViewController: ListChooseViewController())
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        guard let list: TwitterList = ListService.sharedInstance.selectHomeList(0) else {
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
