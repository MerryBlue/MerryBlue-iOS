import UIKit
import TwitterKit
import RxSwift

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileBackgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        self.view.backgroundColor = UIColor.whiteColor()
        self.setNavigationBar()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.setProfiles()
        self.setLogoutButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    internal func onClickLogoutButton(sender: UIButton) {
        TwitterManager.logoutUser()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateInitialViewController()
        self.presentViewController(initialViewController!, animated: true, completion: nil)
    }
    
    private func setProfiles() {
        TwitterManager.requestProfileInformation().subscribe(onNext: { user in
            print("self on ?")
            }, onError: { error in
            }, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(DisposeBag())
        
        // let s: TWTRAuthSession = TwitterManager.getUser()
        nameLabel.text = "アカウントネーム"
        screenNameLabel.text = "@screen_name"
        // TODO:
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

