import UIKit

public protocol SnapImagePickerProtocol {
    var cameraRollAccess: Bool { get set }
    var delegate: SnapImagePickerDelegate? { get set }
    
    static func initializeWithCameraRollAccess(_ cameraRollAccess: Bool) -> SnapImagePickerViewController?
    
    func reload()
    func getCurrentImage() -> (image: UIImage, options: ImageOptions)?
}
