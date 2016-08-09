import UIKit

extension UIImageOrientation {
    func next() -> UIImageOrientation {
        switch self {
        case .Up, .DownMirrored: return .Left
        case .Right, .LeftMirrored: return .Up
        case .Down, .UpMirrored: return .Right
        case .Left, .RightMirrored: return .Down
        }
    }
}