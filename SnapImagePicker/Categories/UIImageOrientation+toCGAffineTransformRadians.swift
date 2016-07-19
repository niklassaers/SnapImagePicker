import UIKit

extension UIImageOrientation {
    func toCGAffineTransformRadians() -> Double {
        switch self {
        case .Up, .DownMirrored: return 0
        case .Right, .LeftMirrored: return M_PI/2
        case .Down, .UpMirrored: return M_PI
        case .Left, .RightMirrored: return M_PI*1.5
        }
    }
}