import UIKit
import TwitterKit

class HomeViewController: TWTRTimelineViewController {
    
    convenience init() {
        let client = TWTRAPIClient()
        let dataSource = TWTRListTimelineDataSource(listSlug: "cps-lab", listOwnerScreenName: "arzzup", APIClient: client)
        self.init(dataSource: dataSource)
        self.setNavigationBar()
        
        self.title = "HomeBoard"
    }
    
    private func setNavigationBar() {
        let iconImage = FAKIonIcons.iosListIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26))
        let switchListButton = UIBarButtonItem(image: iconImage, style: .Plain, target: self, action: "onClickSwitchList")
        
        self.navigationController?.navigationBar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor.blueColor()
        self.navigationItem
        self.navigationItem.title = "HomeBoard"
        self.navigationItem.setRightBarButtonItem(switchListButton, animated: true)
    }
    
    func onClickSwitchList() {
        let vc = UINavigationController(rootViewController: ListChooseViewController())
        self.presentViewController(vc, animated: true, completion: nil)
    }
}