import UIKit

extension UIScrollView {
    func correctBoundsForImageView(imageView: UIImageView) {
        if let image = imageView.image,
            let currentlyVisibleRect = self.getImageBoundsForImageView(imageView) {
            if imageView.bounds.width == imageView.bounds.height {
                let maxRatio = imageView.bounds.width / max(image.size.width, image.size.height)
                let scale = self.zoomScale
                
                let widthRatio = imageView.bounds.width / image.size.width
                let leftMargin = currentlyVisibleRect.minX * widthRatio
                let rightMargin = self.bounds.width - (currentlyVisibleRect.maxX * widthRatio)
                if (leftMargin < 0 || rightMargin < 0) && leftMargin != rightMargin {
                    let imageWidth = image.size.width * maxRatio
                    if imageWidth * scale < imageView.bounds.width {
                        centerScrollViewHorizontally()
                    } else {
                        clearExcessHorizontalMarginForImage(image, withMargins: (left: leftMargin, right: rightMargin))
                    }
                }
                
                let heightRatio = imageView.bounds.width / image.size.height
                let topMargin = currentlyVisibleRect.minY * heightRatio
                let bottomMargin = self.bounds.height - (currentlyVisibleRect.maxY * heightRatio)
                if (topMargin < 0 || bottomMargin < 0) && topMargin != bottomMargin {
                    let imageHeight = image.size.height * maxRatio
                    if imageHeight * scale < imageView.bounds.height {
                        centerScrollViewVertically()
                    } else {
                        clearExcessVerticalMarginForImage(image, withMargins: (top: topMargin, bottom: bottomMargin))
                    }
                }
            }
        }
    }
}

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

extension UIScrollView {
    func clearExcessVerticalMarginForImage(image: UIImage, withMargins margins: (top: CGFloat, bottom: CGFloat)) {
        let margin = (margins.top < 0) ? margins.top : margins.bottom
        let direction = (margins.top < 0) ? -1 : 1
        let verticalOffset = CGFloat(direction) * margin * (self.zoomScale / (image.size.width / image.size.height))
        let targetOffset = CGPoint(x: self.contentOffset.x, y: self.contentOffset.y + verticalOffset)
        
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