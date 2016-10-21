import UIKit

extension UIScrollView {
    func centerFullImageInImageView(imageView: UIImageView?) {
        if let imageView = imageView,
           let image = imageView.image {
            self.setZoomScale(1.0, animated: false)
            let zoomScale = image.findZoomScaleForLargestFullSquare()
            let offset = image.findCenteredOffsetForImageWithZoomScale(zoomScale)
            let scaledOffset = offset * bounds.width / max(image.size.width, image.size.height)
            
            setZoomScale(zoomScale, animated: false)
            setContentOffset(CGPoint(x: scaledOffset, y: scaledOffset), animated: false)
        }
    }
}