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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Twitter.self, Crashlytics.self])
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if TwitterManager.isLogin() {
            self.window!.rootViewController = StoryBoardService.sharedInstance.mainViewController()
        } else {
            self.window!.rootViewController = StoryBoardService.sharedInstance.signInViewController()
        }
        self.window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // print("アプリ閉じそうな時に呼ばれる")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // print("アプリを閉じた時に呼ばれる")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // print("アプリを開きそうな時に呼ばれる")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // print("アプリを開いた時に呼ばれる")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // print("フリックしてアプリを終了させた時に呼ばれる")
    }

}
