import UIKit

extension UIScrollView  {
    func getImageBoundsForImageView(imageView: UIImageView?) -> CGRect? {
        if let imageView = imageView,
           let image = imageView.image {
                return CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            }
    
        return nil
    }
}