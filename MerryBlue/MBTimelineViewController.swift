import Foundation
import TwitterKit

class MBTimelineViewController: TWTRTimelineViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! TWTRTweetTableViewCell
        // let tweetView = cell.tweetView
        // // タップイベントの書き換え
        // tweetView.gestureRecognizers?.removeAll()
        // tweetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MBTimelineViewController.showTweet)))
        return cell
    }
    
    func showTweet() {
        print("show tweet")
        // Swift
        let url = NSURL(string: "twitter://user?screen_name=arzzup")!
        if (UIApplication.sharedApplication().canOpenURL(url)) {
            UIApplication.sharedApplication().openURL(url)
        } else {
            let url = NSURL(string: "http://elzup.com")!
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
