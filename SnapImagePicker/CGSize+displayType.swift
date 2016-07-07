import UIKit

extension CGSize {
    func displayType() -> Display {
        switch self.width {
        case 1024: return .Landscape
        default: return .Portrait
        }
    }
}