import UIKit

class SelectedImageScrollView: UIScrollView {
    private var imageView: UIImageView?
    var image: UIImage? {
        didSet {
            if let image = image {
                if let imageView = imageView {
                    imageView.removeFromSuperview()
                }
                let newImageView = UIImageView(image: image)
                newImageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.width)
                newImageView.contentMode = .ScaleAspectFill
                addSubview(newImageView)
                imageView = newImageView
                setZoomScale(1, animated: false)
                setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }
        }
    }
    
    override func awakeFromNib() {
        minimumZoomScale = 1.0
        maximumZoomScale = 6.0
    }

}
extension SelectedImageScrollView: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}