import Foundation
import UIKit

class LogoutButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: "tapButton:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}