import UIKit

extension CGSize {
    func displayType() -> Display {
        switch self.width {
        case 1024:
            switch self.height {
            case 768: return .Landscape
            case 1366: return .Portrait
            default: return .Portrait
            }
        case 1366: return .Landscape
        default: return .Portrait
        }
    }
}