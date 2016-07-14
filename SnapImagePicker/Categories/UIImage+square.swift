import UIKit

extension UIImage {
    func square() -> UIImage?{
        let x = self.size.width <= self.size.height ? 0 : (self.size.width - self.size.height) / 2
        let y = self.size.height <= self.size.width ? 0 : (self.size.height - self.size.width) / 2
        let width = min(self.size.width, self.size.height)
        let height = width
        let cropRect = CGRect(x: x * self.scale, y: y * self.scale, width: width * self.scale, height: height * self.scale)

        if let cgImage = CGImageCreateWithImageInRect(self.CGImage, cropRect) {
            return UIImage(CGImage: cgImage)
        }

        return nil
    }
}

extension UIImage {
    func findZoomScaleForLargestFullSquare() -> CGFloat {
        return max(size.width, size.height)/min(size.width, size.height)
    }
    
    func findCenteredOffsetForImageWithZoomScale(zoomScale: CGFloat) -> CGFloat {
        return abs(size.height - size.width) * zoomScale / 2
    }
}