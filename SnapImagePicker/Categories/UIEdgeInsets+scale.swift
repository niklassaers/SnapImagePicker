import UIKit

extension UIEdgeInsets {
    func scale(scale: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: top * scale,
                            left: left * scale,
                            bottom: bottom * scale,
                            right: right * scale)
    }
}