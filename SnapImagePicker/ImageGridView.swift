import UIKit

class ImageGridView: UIView {
    static let LineWidth = CGFloat(2.0)
    static let LineColor = UIColor.blackColor()
    
    override func drawRect(rect: CGRect) {
        let oneThirdWidth = rect.size.width / 3
        let oneThirdHeight = rect.size.height / 3
        ImageGridView.LineColor.set()
        for i in 1...2 {
            drawStraightLineFrom(CGPoint(x: 0, y: oneThirdHeight * CGFloat(i)),
                                 to: CGPoint(x: rect.size.width, y: oneThirdHeight * CGFloat(i))).stroke()
            drawStraightLineFrom(CGPoint(x: oneThirdWidth * CGFloat(i), y: 0),
                                 to: CGPoint(x: oneThirdWidth * CGFloat(i), y: rect.size.height)).stroke()
        }
    }
    
    func drawStraightLineFrom(from: CGPoint, to: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(from)
        path.addLineToPoint(to)
        path.lineWidth = ImageGridView.LineWidth
        
        return path
    }
}
