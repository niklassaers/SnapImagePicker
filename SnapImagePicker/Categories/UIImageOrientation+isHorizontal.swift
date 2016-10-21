import UIKit

extension UIImageOrientation {
    func isHorizontal() -> Bool {
        return self == .left || self == .leftMirrored || self == .right || self == .rightMirrored
    }
}
