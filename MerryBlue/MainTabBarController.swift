import Foundation
import UIKit
import FontAwesomeKit

class MainTabBarController: UITabBarController {
    var homeView: HomeViewController!
    var listTlView: ListTimelineViewController!
    
    var homeNavView: UINavigationController!
    var listTlNavView: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        homeView = storyboard.instantiateViewControllerWithIdentifier("homeViewController") as! HomeViewController
        listTlView = ListTimelineViewController()
        
        let homeTabBarItem = UITabBarItem()
        homeTabBarItem.title = "Home"
        homeTabBarItem.image = FAKIonIcons.iosHomeIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26))
        homeTabBarItem.tag = 1
        
        let listTlTabBarItem = UITabBarItem()
        listTlTabBarItem.title = "Account"
        listTlTabBarItem.image = FAKIonIcons.androidPersonIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26))
        listTlTabBarItem.tag = 3
        
        
        homeView.tabBarItem = homeTabBarItem
        listTlView.tabBarItem = listTlTabBarItem
        
        homeNavView = UINavigationController(rootViewController: homeView)
        listTlNavView = UINavigationController(rootViewController: listTlView)
        
        let tabs: Array<UINavigationController> = [homeNavView, listTlNavView]
        
        self.setViewControllers(tabs, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}