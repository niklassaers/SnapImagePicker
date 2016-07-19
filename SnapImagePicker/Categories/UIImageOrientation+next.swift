import UIKit

extension UIImageOrientation {
    func next() -> UIImageOrientation {
        switch self {
        case .Up, .DownMirrored: return .Right
        case .Right, .LeftMirrored: return .Down
        case .Down, .UpMirrored: return .Left
        case .Left, .RightMirrored: return .Up
        }
    }
}