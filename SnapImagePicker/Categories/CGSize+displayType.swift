import UIKit

extension CGSize {
    func displayType() -> Display {
        switch width {
        case 1024:
            if height < width {
                return .Landscape
            } else {
                return .Portrait
            }
        case 1366: return .Landscape
        default: return .Portrait
        }
    }
}