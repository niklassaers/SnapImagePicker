import UIKit

extension CGSize {
    func displayType() -> Display {
        switch width {
        case 1024:
            if height < width {
                return .landscape
            } else {
                return .portrait
            }
        case 1366: return .landscape
        default: return .portrait
        }
    }
}
