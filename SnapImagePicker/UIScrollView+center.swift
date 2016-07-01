import UIKit

extension UIScrollView {
    func centerScrollViewHorizontally() {
        let oldVerticalPosition = self.contentOffset.y
        let oldZoomScale = self.zoomScale
        
        UIView.animateWithDuration(0.3) {
            self.zoomScale = 1
            self.contentOffset = CGPoint(x: 0, y: 0)
            self.zoomScale = oldZoomScale
            self.contentOffset = CGPoint(x: self.contentOffset.x, y: oldVerticalPosition)
        }
    }
    
    func centerScrollViewVertically() {
        let oldHorizontalPosition = self.contentOffset.x
        let oldZoomScale = self.zoomScale
        
        UIView.animateWithDuration(0.3) {
            self.zoomScale = 1
            self.contentOffset = CGPoint(x: 0, y: 0)
            self.zoomScale = oldZoomScale
            self.contentOffset = CGPoint(x: oldHorizontalPosition, y: self.contentOffset.y)
        }
    }
}