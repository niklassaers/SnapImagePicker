import UIKit

extension UIScrollView  {
    func getImageBoundsForImageView(imageView: UIImageView?) -> CGRect? {
        if let imageView = imageView,
            let image = imageView.image {
            let visibleRect = self.convertRect(self.bounds, toView: imageView)
            let ratio = max(image.size.width, image.size.height) / imageView.bounds.width
            let transformedVisibleRect = CGRect(x: visibleRect.minX * ratio,
                                                y: visibleRect.minY * ratio,
                                                width: visibleRect.width * ratio,
                                                height: visibleRect.height * ratio)
    
            var verticalOffset = CGFloat(0.0)
            var horizontalOffset = CGFloat(0.0)
            if image.size.width > image.size.height {
                verticalOffset = (image.size.width - image.size.height) / 2
            } else {
                horizontalOffset = (image.size.height - image.size.width) / 2
            }
    
            let cropRect = CGRect(x: transformedVisibleRect.minX - horizontalOffset,
                                  y: transformedVisibleRect.minY - verticalOffset,
                                  width: transformedVisibleRect.width,
                                  height: transformedVisibleRect.height)
    
            return cropRect
        }
    
        return nil
    }
}