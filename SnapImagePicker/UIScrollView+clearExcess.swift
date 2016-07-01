import UIKit

extension UIScrollView {
    func clearExcessVerticalMarginForImage(image: UIImage, withMargins margins: (top: CGFloat, bottom: CGFloat)) {
        let margin = (margins.top < 0) ? margins.top : margins.bottom
        let direction = (margins.top < 0) ? -1 : 1
        print("Top margin: \(margins.top)")
        print("Old offset: \(self.contentOffset)")
        let verticalOffset = CGFloat(direction) * margin * (self.zoomScale / (image.size.width / image.size.height))
        let targetOffset = CGPoint(x: self.contentOffset.x, y: self.contentOffset.y + verticalOffset)
        print("Vertical offset: \(targetOffset)")
        
        self.setContentOffset(targetOffset, animated: true)
    }
    
    func clearExcessHorizontalMarginForImage(image: UIImage, withMargins margins: (left: CGFloat, right: CGFloat)) {
        let margin = (margins.left < 0) ? margins.left : margins.right
        let direction = (margins.left < 0) ? -1 : 1
        let horizontalOffset = CGFloat(direction) * margin * (self.zoomScale / (image.size.height / image.size.width))
        let targetOffset = CGPoint(x: self.contentOffset.x + horizontalOffset, y: self.contentOffset.y)
        
        self.setContentOffset(targetOffset, animated: true)
    }
}