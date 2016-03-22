import Foundation
import UIKit
import SDWebImage

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
        let url = NSURL(string: listInfo.imageUrl)
        SDWebImageDownloader.sharedDownloader().downloadImageWithURL(url, options: [], progress: nil,
                completed: { [weak self] (image, data, error, finished) in
                    dispatch_async(dispatch_get_main_queue(), {
                        self!.iconImageView.image = image
                    })
            })
        
        if listInfo.enable() {
            memberNumLabel.textColor = UIColor.blackColor()
        } else {
            // 選択不可
            memberNumLabel.textColor = UIColor.redColor()
        }
    }
}
