import Foundation

import UIKit
import TwitterKit

class SwipeableCell: TWTRTweetTableViewCell {
    // For table view referencing
    var identifier:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clearColor()
        self.backgroundColor = .clearColor()
    }
    
}