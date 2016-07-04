import UIKit

class DownwardsArrowView: UIView {
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath()
        let horizontalDistance = CGFloat(0.15)
        let verticalDistance = CGFloat(0.07)
        let verticalOffset = CGFloat(0.05)
        
        path.moveToPoint(CGPoint(x: (0.5 - horizontalDistance) * rect.maxX, y: rect.maxY * (0.5 - verticalDistance + verticalOffset)))
        path.addLineToPoint(CGPoint(x: 0.5 * rect.maxX, y: rect.maxY * (0.5 + verticalDistance + verticalOffset)))
        path.addLineToPoint(CGPoint(x: (0.5 + horizontalDistance) * rect.maxX, y: rect.maxY * (0.5 - verticalDistance + verticalOffset)))
        UIColor.blackColor().set()
        path.stroke()
    }
}
