import Foundation
import UIKit

class UserStatusCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(user: TwitterUser) {
        self.nameLabel.text = user.name
        do {
            let imageData: NSData = try NSData(contentsOfURL: NSURL(string: user.profileImageURL)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            self.iconImageView.image = UIImage(data:imageData)
        } catch {
            print("Error: Image request invalid")
        }
    }
}
