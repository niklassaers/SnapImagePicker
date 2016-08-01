import Foundation
import UIKit

public protocol SnapImagePickerDelegate : class {
    func requestPhotosAccessForImagePicker(callbackDelegate: SnapImagePicker)
    func pickedImage(image: UIImage, withImageOptions: ImageOptions)
}
