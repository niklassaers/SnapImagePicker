import UIKit

func *(left: CGRect, right: CGFloat) -> CGRect {
    return CGRect(x: left.minX * right,
                  y: left.minY * right,
                  width: left.width * right,
                  height: left.height * right)
}

func /(left: CGRect, right: CGFloat) -> CGRect {
    return CGRect(x: left.minX / right,
                  y: left.minY / right,
                  width: left.width / right,
                  height: left.height / right)
}

func +(left: CGRect, right: CGRect) -> CGRect {
    return CGRect(x: left.minX + right.minX,
                  y: left.minY + right.minY,
                  width: left.width + right.width,
                  height: left.height + right.height)
}