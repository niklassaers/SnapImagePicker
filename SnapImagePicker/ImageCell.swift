import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView?
    
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint?
    @IBOutlet weak var bottomMarginConstraint: NSLayoutConstraint?
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint?
    @IBOutlet weak var rightMarginConstraint: NSLayoutConstraint?
    
    var spacing = CGFloat(0.0) {
        didSet {
            topMarginConstraint?.constant = spacing - 8
            bottomMarginConstraint?.constant = spacing - 8
            leftMarginConstraint?.constant = spacing - 8
            rightMarginConstraint?.constant = spacing - 8
        }
    }
    
    override func prepareForReuse() {
        imageView?.image = nil
        spacing = 0.0
    }
}
