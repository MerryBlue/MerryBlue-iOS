import UIKit
import Fabric
import Crashlytics
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var userViewScreenName: String?
    var userViewUser: TwitterUser?
    var userViewNewCount: Int?
    var openHomeID: Int?
    var homeList: MBTwitterList?

    var showTweet: MBTweet?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Twitter.self, Crashlytics.self])
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        if TwitterManager.isLogin() {
            self.window!.rootViewController = StoryBoardService.sharedInstance.mainViewController()
        } else {
            self.window!.rootViewController = StoryBoardService.sharedInstance.signInViewController()
        }
        self.window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // print("アプリ閉じそうな時に呼ばれる")
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // print("アプリを閉じた時に呼ばれる")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // print("アプリを開きそうな時に呼ばれる")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // print("アプリを開いた時に呼ばれる")
    }

    func applicationWillTerminate(application: UIApplication) {
        // print("フリックしてアプリを終了させた時に呼ばれる")
    }

}
