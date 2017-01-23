import TwitterKit
import SwiftyJSON

open class MBTweet: TWTRTweet {

    var imageURLs: [String]!

    public override init() {
        super.init()
    }

    public required override init!(jsonDictionary dictionary: [AnyHashable: Any]!) {
        super.init(jsonDictionary: dictionary)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func hasMedia() -> Bool {
        return self.imageURLs.count > 0
    }

    override func arrangeText() -> String {
        var text = super.arrangeText()
        if self.hasMedia() {
            text = "🖼" + text
        }
        return text
    }

    init?(json: SwiftyJSON.JSON) {
        super(jsonDictionary: json.dictionaryObject)
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
