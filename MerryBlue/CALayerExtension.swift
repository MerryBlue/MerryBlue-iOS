import Foundation

extension CALayer {

    func addBorder(_ edge: UIRectEdge, color: UIColor, thickness: CGFloat) {

        let border = CALayer()

        switch edge {
        case UIRectEdge.Top:
            border.frame = CGRect.init(x: 0, y: 0, width: CGRectGetHeight(self.frame), height: thickness)
            break
        case UIRectEdge.Bottom:
            border.frame = CGRect.init(x: 0, y: CGRectGetHeight(self.frame) - thickness, width: UIScreen.mainScreen().bounds.width, height: thickness)
            break
        case UIRectEdge.Left:
            border.frame = CGRect.init(x: 0, y: 0, width: thickness, height: CGRectGetHeight(self.frame))
            break
        case UIRectEdge.Right:
            border.frame = CGRect.init(x: CGRectGetWidth(self.frame) - thickness, y: 0, width: thickness, height: CGRectGetHeight(self.frame))
            break
        default:
            break
        }

        border.backgroundColor = color.CGColor

        self.addSublayer(border)
    }

}
