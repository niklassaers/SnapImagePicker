import UIKit

extension UIImageView {
    func translateRect(rect: CGRect, forImage image: UIImage) -> CGRect {
        let verticalRatio = image.size.height / frame.height
        let horizontalRatio = image.size.width / frame.width
        
        return CGRect(x: rect.minX * horizontalRatio,
                      y: rect.minY * verticalRatio,
                      width: rect.width * horizontalRatio,
                      height: rect.height * verticalRatio)
    }
}