import UIKit

// プロトコルを追加
class PhotoViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var viewerImgView: UIImageView!

    var viewerImg: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        self.viewerImgView.contentMode = .ScaleAspectFit
        self.viewerImgView.image = viewerImg
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ピンチイン・ピンチアウト時に呼ばれる
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return viewerImgView
    }

}
