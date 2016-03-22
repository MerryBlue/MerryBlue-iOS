import Foundation
import UIKit
import TwitterKit
import SlideMenuControllerSwift

class SignInViewController: UIViewController {
    
    @IBOutlet weak var logInButtonView: UIView?
    var delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logInButton = TWTRLogInButton { (session, error) in
            if session != nil {
                UIApplication.sharedApplication().keyWindow?.rootViewController = MainTabBarController()
                self.presentMainTabBarController()
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }
        
        logInButton.center = self.logInButtonView!.center
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
        let leftMenuView = storyboard.instantiateViewControllerWithIdentifier("leftmenu")
        let slideMenuController = SlideMenuController(mainViewController: mainView, leftMenuViewController: leftMenuView)
        self.presentViewController(slideMenuController, animated: true, completion: nil)
    }
}