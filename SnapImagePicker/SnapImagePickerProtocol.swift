import UIKit

public protocol SnapImagePickerProtocol {
    func initializeViewControllerWithPhotosAccess(hasPhotosAccess: Bool) -> SnapImagePickerViewController?
    func photosAccessStatusChanged()
}
