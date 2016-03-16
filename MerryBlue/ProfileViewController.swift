import UIKit
import TwitterKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.setNavigationBar()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.setLogoutButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    internal func onClickLogoutButton(sender: UIButton) {
        let store = Twitter.sharedInstance().sessionStore
        if let userID = store.session()!.userID {
            store.logOutUserID(userID)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateInitialViewController()
        self.presentViewController(initialViewController!, animated: true, completion: nil)
    }
    
    private func setLogoutButton() {
        logoutButton.addTarget(self, action: "onClickLogoutButton:", forControlEvents: .TouchUpInside)
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // self.navigationController?.navigationBar.barTintColor = UIColor.blueColor()
        // self.navigationController?.navigationBar.alpha = 0.1
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem
        self.navigationItem.title = "Account"
    }
}

