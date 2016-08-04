import UIKit

extension UIScrollView  {
    func getImageBoundsForImageView(imageView: UIImageView?) -> CGRect? {
        if let imageView = imageView,
           let image = imageView.image {
            let verticalRatio = image.size.width / imageView.frame.width
            let horizontalRatio = image.size.height / imageView.frame.height
            let visibleRect = convertRect(bounds, toView: imageView)
            
            let cropRect = CGRect(x: visibleRect.minX * horizontalRatio,
                                  y: visibleRect.minY * verticalRatio,
                                  width: visibleRect.width * horizontalRatio,
                                  height: visibleRect.height * verticalRatio)
            }
    
        return nil
    }
}