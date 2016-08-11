import UIKit

extension UIButton {
    func rightAlignImage(image: UIImage) {
        if let titleLabel = titleLabel {
            titleLabel.sizeToFit()
            imageEdgeInsets = UIEdgeInsetsMake(0, titleLabel.frame.width + 6, 0, -(titleLabel.frame.width + 6));
            titleEdgeInsets = UIEdgeInsetsMake(0, -image.size.width, 0, image.size.width);
        }
    }
}