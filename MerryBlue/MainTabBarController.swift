import Foundation
import UIKit
import FontAwesomeKit

class MainTabBarController: UITabBarController {
    var listTlView: ListTimelineViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        listTlView = ListTimelineViewController()

        let listTlTabBarItem = UITabBarItem(
            title: "Timeline",
            image: FAKIonIcons.androidHomeIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26)),
            tag: 2)

        listTlView.tabBarItem = listTlTabBarItem


        self.styles()
        // self.setViewControllers(tabs, animated: false)
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
