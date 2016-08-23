import UIKit

extension UIEdgeInsets {
    func addVerticalInset(inset: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: top + inset,
                            left: left,
                            bottom: bottom + inset,
                            right: right)
    }
    
    func addHorizontalInset(inset: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: top,
                            left: left + inset,
                            bottom: bottom,
                            right: right + inset)
    }
}