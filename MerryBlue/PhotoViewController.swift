import UIKit

// プロトコルを追加
class PhotoViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    var viewerImg: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 8
        self.scrollView.scrollEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = true
        self.scrollView.showsVerticalScrollIndicator = true

        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoViewController.doubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.imageView.userInteractionEnabled = true
        self.imageView.addGestureRecognizer(doubleTapGesture)
    }

    func doubleTap(gesture: UITapGestureRecognizer) -> Void {

        // print(self.scrollView.zoomScale)
        if self.scrollView.zoomScale < self.scrollView.maximumZoomScale {

            let newScale: CGFloat = self.scrollView.zoomScale * 3
            let zoomRect: CGRect = self.zoomRectForScale(newScale, center: gesture.locationInView(gesture.view))
            self.scrollView.zoomToRect(zoomRect, animated: true)

        } else {
            self.scrollView.setZoomScale(1.0, animated: true)
        }
    }

    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect: CGRect = CGRect()
        zoomRect.size.height = self.scrollView.frame.size.height / scale
        zoomRect.size.width = self.scrollView.frame.size.width / scale

        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0

        return zoomRect
    }

    override func viewDidAppear(animated: Bool) {
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.image = viewerImg
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ピンチイン・ピンチアウト時に呼ばれる
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}
