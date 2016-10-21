import UIKit

extension UIImage {
    func findRoundedScale(_ scale: CGFloat) -> CGFloat {
        if size.width / scale != ceil(size.width / scale) {
            let roundedResult = ceil(size.width / scale)
            return size.width / roundedResult
        }
        
        return scale
    }
}
