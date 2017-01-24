import Foundation
import UIKit

class MBNavigationController: UINavigationController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.setNavigationBarHidden(false, animated: false)
        self.navigationBar.isTranslucent = false
    }

}
