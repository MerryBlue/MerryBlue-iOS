import Foundation
import UIKit
import TwitterKit
import SlideMenuControllerSwift

class SignInViewController: UIViewController {

    @IBOutlet weak var logInButtonView: UIView?
    let delegate = (UIApplication.sharedApplication().delegate as? AppDelegate)

    override func viewDidLoad() {
        super.viewDidLoad()
        let logInButton = TWTRLogInButton { (session, error) in
            if session != nil {
                UIApplication.sharedApplication().keyWindow?.rootViewController = MainTabBarController()
                self.presentMainTabBarController()
            } else {
                NSLog("Login error: %@", error!.localizedDescription)
            }
        }

        guard let loginBtnView = self.logInButtonView else {
            print("Error: loginButtonView not loaded")
            return
        }
        logInButton.center = CGPoint(x: self.view.center.x, y: loginBtnView.center.y)
        // logInButtonView?.addSubview(logInButton)
        // self.logInButtonView!.addSubview(logInButton)
        self.view.addSubview(logInButton)
    }

    override func viewDidAppear(animated: Bool) {
        guard let _ = TwitterManager.getUserID() else {
            return
        }
        self.presentMainTabBarController()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

    private func presentMainTabBarController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainView = storyboard.instantiateViewControllerWithIdentifier("main")
        let leftMenuView = storyboard.instantiateViewControllerWithIdentifier("menu")
        let slideMenuController = SlideMenuController(mainViewController: mainView, leftMenuViewController: leftMenuView)
        // self.presentViewController(slideMenuController, animated: true, completion: nil)
        UIApplication.sharedApplication().keyWindow?.rootViewController = slideMenuController
    }

}
