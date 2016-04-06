import SDWebImage

extension SDWebImageDownloader {
    static func setImageSync(imageView: UIImageView, url: NSURL) {
        SDWebImageDownloader
            .sharedDownloader()
            .downloadImageWithURL(url, options: [], progress: nil, completed: {
                (image, data, error, finished) in
                dispatch_async(dispatch_get_main_queue()) {
                    imageView.image = image
                }
            })
    }

}
