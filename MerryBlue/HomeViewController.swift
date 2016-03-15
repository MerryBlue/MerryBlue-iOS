import UIKit
import TwitterKit
import FontAwesomeKit

class HomeViewController: TWTRTimelineViewController {
    
    var listId: String!
    convenience init() {
        guard let listId: String = ConfigManager.getListId() else {
            self.init()
            self.openListsChooser()
            return
        }
        let client = TwitterManager.getClient()
        let dataSource = TWTRListTimelineDataSource(listID: listId, APIClient: client)
        self.init(dataSource: dataSource)
        self.title = "HomeBoard"
        self.setNavigationBar()
        self.listId = listId
        TwitterManager.getListUsers(listId)
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
        self.navigationItem.title = "HomeBoard"
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
        guard let listId: String = ConfigManager.getListId() else {
            self.openListsChooser()
            return
        }
        if (self.listId == listId) {
            return
        }
        let client = TwitterManager.getClient()
        let dataSource = TWTRListTimelineDataSource(listID: listId, APIClient: client)
        self.dataSource = dataSource
        self.refresh()
        self.listId = listId
    }
}