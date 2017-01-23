import Foundation

extension Date {

    func toFuzzy() -> String {
        let now = Date()

        let cal = Calendar.current
        let components = (cal as NSCalendar).components([.year, .day, .hour, .minute, .second], from: self, to: now, options: [])

        let cMinute = components.minute! * 60
        let cHour = components.hour! * 3600
        let cDay = components.day! * 86400
        let cYear = components.year! * 31536000
        let diffSec = components.second! + cMinute + cHour + cDay + cYear
        
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
            let dateFormatter = DateFormatter()

            if components.year! > 0 {
                dateFormatter.dateFormat = "yyyy年M月d日"
                result = dateFormatter.string(from: self)
            } else {
                dateFormatter.dateFormat = "M月d日"
                result = dateFormatter.string(from: self)
            }
        }

        return result
    }

    static func parse(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"
        let d = formatter.date(from: dateString)
        return Date(timeInterval: 0, since: d!)
    }

}
