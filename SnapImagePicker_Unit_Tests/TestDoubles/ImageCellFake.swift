@testable import SnapImagePicker
import UIKit

class ImageCellMock: ImageCell {
    private var _imageView = UIImageView()
    override var imageView: UIImageView? {
        get {
            return _imageView
        }
        set {
            return
        }
    }
}