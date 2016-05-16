class ImageCellInfo {
    let imageURL: String
    let tweet: MBTweet
    var counts: Int

    init(imageURL: String, tweet: MBTweet) {
        self.imageURL = imageURL
        self.tweet = tweet
        self.counts = 0
    }
}
