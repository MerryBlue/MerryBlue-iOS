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

        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())

        homeView = (storyboard.instantiateViewControllerWithIdentifier("home") as? HomeViewController)
        listTlView = ListTimelineViewController()

        let homeTabBarItem = UITabBarItem(
            title: "Home",
            image: FAKIonIcons.androidContactsIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26)),
            tag: 1
        )

        let listTlTabBarItem = UITabBarItem(
            title: "Timeline",
            image: FAKIonIcons.androidHomeIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26)),
            tag: 2)

        homeView.tabBarItem = homeTabBarItem
        listTlView.tabBarItem = listTlTabBarItem

        homeNavView = MBNavigationController(rootViewController: homeView)
        listTlNavView = MBNavigationController(rootViewController: listTlView)

        let tabs = [homeNavView, listTlNavView] as Array<UINavigationController>

        self.styles()
        self.setViewControllers(tabs, animated: false)
    }

    func styles() {
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: MBColor.Sub], forState: UIControlState.Selected)
        UITabBar.appearance().tintColor = MBColor.Sub
        UITabBar.appearance().barTintColor = MBColor.Dark
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
