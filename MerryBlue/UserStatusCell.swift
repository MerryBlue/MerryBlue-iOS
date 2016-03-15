import Foundation
import UIKit

class UserStatusCell: UITableViewCell {
    var nameLabel: UILabel!
    var iconImage: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        nameLabel = UILabel(frame: CGRectMake(100, 0, 300, 15))
        nameLabel.text = ""
        iconImage = UIImageView(frame: CGRectMake(0, 0, 100, 100))
        
        self.addSubview(nameLabel)
        self.addSubview(iconImage)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    func setCell(user: TwitterUser) {
        self.nameLabel.text = user.name
        do {
            let imageData: NSData = try NSData(contentsOfURL: NSURL(string: user.profileImageURL)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            self.iconImage.image = UIImage(data:imageData)
        } catch {
            print("Error: Image request invalid")
        }
    }
}
