import Foundation
import UIKit
import FontAwesomeKit

class MainTabBarController: UITabBarController {
    var homeView: HomeViewController!
    var profileView: ProfileViewController!
    
    var homeNavView: UINavigationController!
    var profileNavView: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        homeView = storyboard.instantiateViewControllerWithIdentifier("homeViewController") as! HomeViewController
        
        profileView = ProfileViewController()
        
        let homeTabBarItem = UITabBarItem()
        homeTabBarItem.title = "Home"
        homeTabBarItem.image = FAKIonIcons.iosHomeIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26))
        homeTabBarItem.tag = 1
        let profileTabBarItem = UITabBarItem()
        profileTabBarItem.title = "Account"
        profileTabBarItem.image = FAKIonIcons.androidPersonIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26))
        homeTabBarItem.tag = 2
        
        
        homeView.tabBarItem = homeTabBarItem
        profileView.tabBarItem = profileTabBarItem
        
        homeNavView = UINavigationController(rootViewController: homeView)
        profileNavView = UINavigationController(rootViewController: profileView)
        
        let tabs: Array<UINavigationController> = [homeNavView, profileNavView]
        
        self.setViewControllers(tabs, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}