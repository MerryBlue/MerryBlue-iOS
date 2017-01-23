import Foundation
import UIKit
import TwitterKit

class SignInViewController: UIViewController {

    @IBOutlet weak var logInButtonView: UIView?
    let delegate = (UIApplication.shared.delegate as? AppDelegate)

    override func viewDidLoad() {
        super.viewDidLoad()
        let logInButton = TWTRLogInButton { (session, error) in
            if session != nil {
                self.presentMainTabBarController()
            } else {
                NSLog("Login error: %@", error!.localizedDescription)
            }
        }

        guard let loginBtnView = self.logInButtonView else {
            print("Error: loginButtonView not loaded")
            return
        }
        logInButton?.center = CGPoint(x: self.view.center.x, y: self.view.frame.height - (loginBtnView.frame.height / 2))
        // logInButtonView?.addSubview(logInButton)
        // self.logInButtonView!.addSubview(logInButton)
        self.view.addSubview(logInButton!)
    }

    override func viewDidAppear(_ animated: Bool) {
        guard let _ = TwitterManager.getUserID() else {
            return
        }
        self.presentMainTabBarController()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

    fileprivate func presentMainTabBarController() {
        UIApplication.shared.keyWindow?.rootViewController = StoryBoardService.sharedInstance.mainViewController()
    }

}
