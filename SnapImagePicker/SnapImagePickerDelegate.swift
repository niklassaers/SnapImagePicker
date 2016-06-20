import Foundation

public protocol SnapImagePickerDelegate : class {
    func pickedImage(image: UIImage, withBounds: CGRect)
}
