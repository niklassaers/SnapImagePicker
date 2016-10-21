import UIKit

extension UIImageOrientation {
    func toCGAffineTransformRadians() -> Double {
        switch self {
        case .up, .downMirrored: return 0
        case .right, .leftMirrored: return M_PI/2
        case .down, .upMirrored: return M_PI
        case .left, .rightMirrored: return M_PI*1.5
        }
    }
}
