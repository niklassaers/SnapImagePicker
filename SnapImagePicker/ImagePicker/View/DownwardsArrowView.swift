import UIKit

class DownwardsArrowView: UIView {
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        let horizontalDistance = CGFloat(0.5)
        let verticalDistance = CGFloat(0.11)
        let verticalOffset = CGFloat(0.05)
        
        path.move(to: CGPoint(x: (0.5 - horizontalDistance) * rect.maxX, y: rect.maxY * (0.5 - verticalDistance + verticalOffset)))
        path.addLine(to: CGPoint(x: 0.5 * rect.maxX, y: rect.maxY * (0.5 + verticalDistance + verticalOffset)))
        path.addLine(to: CGPoint(x: (0.5 + horizontalDistance) * rect.maxX, y: rect.maxY * (0.5 - verticalDistance + verticalOffset)))
        UIColor.black.set()
        path.stroke()
    }
}
