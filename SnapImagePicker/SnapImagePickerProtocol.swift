import UIKit

public protocol SnapImagePickerProtocol {
    func initializeViewControllerWithNavigationController(navigationController: UINavigationController) -> UIViewController?
    func photosAccessStatusChanged()
}
