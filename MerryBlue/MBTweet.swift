import TwitterKit
import SwiftyJSON

public class MBTweet: TWTRTweet {

    var imageURLs: [String]!
    var exAuthor: TwitterUser!

    public required override init!(JSONDictionary dictionary: [NSObject: AnyObject]!) {
        super.init(JSONDictionary: dictionary)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func hasMedia() -> Bool {
        return self.imageURLs.count > 0
    }

    override func arrangeText() -> String {
        var text = super.arrangeText()
        if self.hasMedia() {
            text = "🖼" + text
        }
        return text
    }

    public func setAuthor(user: TwitterUser) {
        self.exAuthor = user
    }

    public func getExAuthorURL() -> TWTRUser {
        guard let author = self.author else {
            return self.exAuthor
        }
        return author
    }

    init?(json: SwiftyJSON.JSON) {
        super.init(JSONDictionary: json.dictionaryObject)
        var medias = json["entities"]["media"].arrayValue
        if json["extended_entities"]["media"].arrayValue.count > 0 {
            medias = json["extended_entities"]["media"].arrayValue
        }
        if medias.count > 0 {
            imageURLs = medias.map { $0["media_url_https"].stringValue }
        } else {
            imageURLs = []
        }
    }

}
