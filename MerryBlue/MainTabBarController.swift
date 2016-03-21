import Foundation
import UIKit
import FontAwesomeKit

class MainTabBarController: UITabBarController {
    var homeView: HomeViewController!
    var homeViewB: HomeViewController!
    var profileView: ProfileViewController!
    
    var homeNavView: UINavigationController!
    var homeNavViewB: UINavigationController!
    var profileNavView: UINavigationController!
    static var homeID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        homeView = storyboard.instantiateViewControllerWithIdentifier("homeViewController") as! HomeViewController
        homeViewB = storyboard.instantiateViewControllerWithIdentifier("homeViewController") as! HomeViewController
        profileView = storyboard.instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
        
        let homeTabBarItem = UITabBarItem()
        homeTabBarItem.title = "Home"
        homeTabBarItem.image = FAKIonIcons.iosHomeIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26))
        homeTabBarItem.tag = 1
        
        let homeTabBarItemB = UITabBarItem()
        homeTabBarItemB.title = "Home"
        homeTabBarItemB.image = FAKIonIcons.iosHomeIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26))
        homeTabBarItemB.tag = 2
        
        let profileTabBarItem = UITabBarItem()
        profileTabBarItem.title = "Account"
        profileTabBarItem.image = FAKIonIcons.androidPersonIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26))
        profileTabBarItem.tag = 3
        
        
        homeView.tabBarItem = homeTabBarItem
        homeViewB.tabBarItem = homeTabBarItemB
        profileView.tabBarItem = profileTabBarItem
        
        homeNavView = UINavigationController(rootViewController: homeView)
        homeNavViewB = UINavigationController(rootViewController: homeViewB)
        profileNavView = UINavigationController(rootViewController: profileView)
        
        let tabs: Array<UINavigationController> = [homeNavView, homeNavViewB, profileNavView]
        
        self.setViewControllers(tabs, animated: false)
    }
    
    static func getHomeID() -> Int {
        homeID += 1
        return homeID
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}