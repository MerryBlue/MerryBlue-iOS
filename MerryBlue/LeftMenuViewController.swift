import UIKit
import TwitterKit
import RxSwift

class LeftMenuViewController: UIViewController {
    
    @IBOutlet weak var profileBackgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    var user: TwitterUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        if user == nil {
            _ = TwitterManager.requestUserProfile(TwitterManager.getUserID()).subscribeNext({ (user) -> Void in self.setProfiles(user)})
        }
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
    
    private func setProfiles(user: TwitterUser) {
        nameLabel.text = user.name
        screenNameLabel.text = "@\(user.screenName)"
        do {
            let imageData: NSData = try NSData(contentsOfURL: NSURL(string: user.profileImageURL)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            let bgImageData: NSData = try NSData(contentsOfURL: NSURL(string: user.profileBackgroundImageURL)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            self.profileImageView.image = UIImage(data: imageData)
            self.profileBackgroundImageView.image = UIImage(data: bgImageData)
        } catch {
            print("Error: Image request invalid")
        }
    }
    
    private func setLogoutButton() {
        logoutButton.addTarget(self, action: #selector(ProfileViewController.onClickLogoutButton(_:)), forControlEvents: .TouchUpInside)
    }
    
}
