import Foundation

class MBNavigationController: UINavigationController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.setNavigationBarHidden(false, animated: false)
        self.navigationBar.barTintColor = MBColor.Main
        self.navigationBar.tintColor = MBColor.Back
        self.navigationBar.translucent = false

        self.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName: MBColor.Back ]
    }

}
