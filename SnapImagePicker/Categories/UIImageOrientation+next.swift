import UIKit

extension UIImageOrientation {
    func next() -> UIImageOrientation {
        switch self {
        case .up, .downMirrored: return .left
        case .right, .leftMirrored: return .up
        case .down, .upMirrored: return .right
        case .left, .rightMirrored: return .down
        }
    }
}
