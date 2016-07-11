import UIKit

extension UIScrollView {
    func centerFullImageInImageView(imageView: UIImageView?) {
        if let imageView = imageView,
           let image = imageView.image {
            self.setZoomScale(1.0, animated: false)
            imageView.contentMode = .ScaleAspectFit
            
            // Necessary circularity?
            imageView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: frame.width,
                                     height: frame.height)
            contentSize = CGSize(width: imageView.bounds.width,
                                 height: imageView.bounds.height)
            
            let zoomScale = image.findZoomScaleForLargestFullSquare()
            print("Zoom scale: \(zoomScale)")
            let offset = image.findCenteredOffsetForImageWithZoomScale(zoomScale)
            let scaledOffset = offset * bounds.width / max(image.size.width, image.size.height)
            print("Scaled offset: \(scaledOffset)")
            
            setZoomScale(zoomScale, animated: false)
            setContentOffset(CGPoint(x: scaledOffset, y: scaledOffset), animated: false)
        }
    }
}