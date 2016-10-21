import UIKit

extension UIScrollView {
    fileprivate func calculateOffsetFromVelocity(_ velocity: CGPoint) -> CGPoint {
        var offset = CGPoint.zero
        
        let x = Double(velocity.x / abs(velocity.x)) * pow(Double(28 * log(abs(velocity.x)) + 25), 1.2) * 0.6
        let y = Double(velocity.y / abs(velocity.y)) * pow(Double(28 * log(abs(velocity.y)) + 25), 1.2) * 0.6
        if !x.isNaN {
            offset.x = CGFloat(x)
        }
        if !y.isNaN {
            offset.y = CGFloat(y)
        }
        
        return offset
    }
    func manuallyBounceBasedOnVelocity(_ velocity: CGPoint, withAnimationDuration duration: Double = 0.2) {
        let originalOffset = contentOffset
        
        let offset = calculateOffsetFromVelocity(velocity)
    
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            [weak self] in
            if let strongSelf = self {
                strongSelf.setContentOffset(CGPoint(x: originalOffset.x + offset.x, y: originalOffset.y + offset.y), animated: false)
            }
            }, completion: {
                [weak self] (_) in
                UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                        if let strongSelf = self {
                            strongSelf.setContentOffset(originalOffset, animated: false)
                        }
                    }, completion: nil)
            })
    }
}
