import Foundation

extension NSDate {
    func toFuzzy() -> String {
        let now = NSDate()
        
        let cal = NSCalendar.currentCalendar()
        // let calUnit: NSCalendarUnit = [.Second | .Minute | .Hour | .Day | .Year]
        let components = cal.components([.Year, .Day, .Hour, .Minute, .Second], fromDate: self, toDate: now, options: [])
        
        let diffSec = components.second + components.minute*60 + components.hour*3600 + components.day*86400 + components.year*31536000
        var result = String()
        
        if diffSec < 60 {
            result = "\(diffSec)秒前"
        } else if diffSec < 3600 {
            result = "\(diffSec/60)分前"
        } else if diffSec < 86400 {
            result = "\(diffSec/3600)時間前"
        } else if diffSec < 2764800 {
            result = "\(diffSec/86400)日前"
        } else {
            let dateFormatter = NSDateFormatter()
            
            if components.year > 0 {
                dateFormatter.dateFormat = "yyyy年M月d日"
                result = dateFormatter.stringFromDate(self)
            } else {
                dateFormatter.dateFormat = "M月d日"
                result = dateFormatter.stringFromDate(self)
            }
        }
        
        return result
    }
    
    class func parse(dateString:String) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"
        let d = formatter.dateFromString(dateString)
        return NSDate(timeInterval: 0, sinceDate: d!)
    }
}
