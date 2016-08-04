import UIKit

public protocol SnapImagePickerProtocol {
    func initializeViewControllerWithNavigationController(navigationController: UINavigationController, hasPhotosAccess: Bool) -> UIViewController?
    func photosAccessStatusChanged()
}
