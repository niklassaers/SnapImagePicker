//import Foundation
//
//extension UIScrollView  {
//    func getImageBoundsForImageView(imageView: UIImageView?) -> CGRect? {
//        if let scrollView = scrollView,
//            let imageView = imageView,
//            let image = imageView.image {
//            let visibleRect = scrollView.convertRect(scrollView.bounds, toView: imageView)
//            let ratio = max(image.size.width, image.size.height) / imageView.bounds.width
//            let transformedVisibleRect = CGRect(x: visibleRect.minX * ratio,
//                                                y: visibleRect.minY * ratio,
//                                                width: visibleRect.width * ratio,
//                                                height: visibleRect.height * ratio)
//            
//            var verticalOffset = CGFloat(0.0)
//            var horizontalOffset = CGFloat(0.0)
//            if image.size.width > image.size.height {
//                verticalOffset = (image.size.width - image.size.height) / 2
//            } else {
//                horizontalOffset = (image.size.height - image.size.width) / 2
//            }
//            
//            let cropRect = CGRect(x: transformedVisibleRect.minX - horizontalOffset,
//                                  y: transformedVisibleRect.minY - verticalOffset,
//                                  width: transformedVisibleRect.width,
//                                  height: transformedVisibleRect.height)
//            
//            return cropRect
//        }
//        
//        return nil
//    }
//}
//
//extension UIImage {
//
//    func squareImage() -> UIImage?{
//        let x = image.size.width <= image.size.height ? 0 : (image.size.width - image.size.height) / 2
//        let y = image.size.height <= image.size.width ? 0 : (image.size.height - image.size.width) / 2
//        let width = min(image.size.width, image.size.height)
//        let height = min(image.size.width, image.size.height)
//        let cropRect = CGRect(x: x * image.scale, y: y * image.scale, width: width * image.scale, height: height * image.scale)
//        
//        if let cgImage = CGImageCreateWithImageInRect(image.CGImage, cropRect) {
//            return UIImage(CGImage: cgImage)
//        }
//        
//        return nil
//    }
//}