import UIKit

public protocol SnapImagePickerProtocol {
    func initializeViewControllerWithNavigationController(hasPhotosAccess: Bool) -> SnapImagePickerViewController?
    func photosAccessStatusChanged()
}
