import Foundation
import UIKit

class ListInfoCell: UITableViewCell {
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var memberNumLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(listInfo: TwitterList) {
        self.listNameLabel.text = listInfo.name
        self.memberNumLabel.text = String(listInfo.member_count)
        do {
            let imageData: NSData = try NSData(contentsOfURL: NSURL(string: listInfo.user.profileImageURL)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            self.iconImageView.image = UIImage(data:imageData)
        } catch {
            print("Error: Image request invalid")
        }
    }
}
