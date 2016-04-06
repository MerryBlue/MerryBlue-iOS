import TwitterKit
import SwiftyJSON

class MBTweet: TWTRTweet {

    var imageURLs: [String]!

    required override init!(JSONDictionary dictionary: [NSObject: AnyObject]!) {
        super.init(JSONDictionary: dictionary)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init?(json: SwiftyJSON.JSON) {
        super.init(JSONDictionary: json.dictionaryObject)
        let medias = json["entities"]["media"].arrayValue
        if medias.count > 0 {
            imageURLs = medias.map { $0["media_url_https"].stringValue }
        } else {
            imageURLs = []
        }
    }

}
