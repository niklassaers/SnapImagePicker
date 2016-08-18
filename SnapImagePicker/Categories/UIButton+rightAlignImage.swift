import UIKit

extension UIButton {
    func rightAlignImage(image: UIImage) {
        if let titleLabel = titleLabel {
            titleLabel.sizeToFit()
            imageEdgeInsets = UIEdgeInsetsMake(2, titleLabel.frame.width + 4, -2, -(titleLabel.frame.width + 4));
            titleEdgeInsets = UIEdgeInsetsMake(0, -image.size.width, 0, image.size.width);
        }
    }
}