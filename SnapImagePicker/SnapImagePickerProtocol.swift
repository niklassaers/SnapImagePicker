import UIKit

public protocol SnapImagePickerProtocol {
    func initializeViewController() -> UIViewController?
    func photosAccessStatusChanged()
}
