import UIKit
import TwitterKit
import FontAwesomeKit

class UserTimelineViewController: TWTRTimelineViewController {
    
    var delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    convenience init() {
        guard let screenName = (UIApplication.sharedApplication().delegate as! AppDelegate).userViewScreenName else {
            self.init()
            self.goBack()
            return
        }
        let client = TwitterManager.getClient()
        let dataSource = TWTRUserTimelineDataSource(screenName: screenName, APIClient: client)
        self.init(dataSource: dataSource)
        self.title = "Timeline"
        self.setNavigationBar()
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
        self.navigationItem.title = self.title
        self.navigationItem.setRightBarButtonItem(switchListButton, animated: true)
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