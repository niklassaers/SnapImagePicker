import UIKit

extension UIImageOrientation {
    func isHorizontal() -> Bool {
        return self == .Left || self == .LeftMirrored || self == .Right || self == .RightMirrored
    }
}