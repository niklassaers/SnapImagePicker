import UIKit

extension UIEdgeInsets {
    func addVerticalInset(_ inset: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: top + inset,
                            left: left,
                            bottom: bottom + inset,
                            right: right)
    }
    
    func addHorizontalInset(_ inset: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: top,
                            left: left + inset,
                            bottom: bottom,
                            right: right + inset)
    }
}
