import Foundation
import UIKit

public protocol SnapImagePickerDelegate : class {
    func requestPhotosAccess()
    func pickedImage(image: UIImage, withBounds: CGRect)
}
