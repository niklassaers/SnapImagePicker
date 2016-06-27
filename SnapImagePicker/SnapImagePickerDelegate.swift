import Foundation
import UIKit

public protocol SnapImagePickerDelegate : class {
    func pickedImage(image: UIImage, withBounds: CGRect)
}
