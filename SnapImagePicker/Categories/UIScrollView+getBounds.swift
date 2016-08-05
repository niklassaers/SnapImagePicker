import UIKit

extension UIScrollView  {
    func getImageBoundsForImageView(imageView: UIImageView?) -> CGRect? {
        if let imageView = imageView,
           let image = imageView.image {
            let viewRect = translateBoundsToCoordinatesForView(imageView)
            let translatedRect = imageView.translateRect(viewRect, forImage: image)
            return translatedRect
        }
    
        return nil
    }
    
    private func translateBoundsToCoordinatesForView(imageView: UIImageView) -> CGRect {
        return CGRect(x: contentOffset.x,
                      y: contentOffset.y,
                      width: frame.width,
                      height: frame.height)
    }
}