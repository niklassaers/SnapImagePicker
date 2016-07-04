import UIKit

class DownwardsArrowView: UIView {
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath()
        let horizontalOffset = CGFloat(0.2)
        let verticalOffset = CGFloat(0.15)
        path.moveToPoint(CGPoint(x: (0.5 - horizontalOffset) * rect.maxX, y: (0.5 - verticalOffset) * rect.maxY))
        path.addLineToPoint(CGPoint(x: 0.5 * rect.maxX, y: (0.5 + verticalOffset) * rect.maxY))
        path.addLineToPoint(CGPoint(x: (0.5 + horizontalOffset) * rect.maxX, y: (0.5 - verticalOffset) * rect.maxY))
        UIColor.blackColor().set()
        path.stroke()
    }
}
