import UIKit

protocol SnapImagePickerEventHandlerProtocol: class {
    func viewWillAppear()
    func albumIndexClicked(index: Int)
    func flipImageButtonPressed()
    func albumTitleClicked(destinationViewController: UIViewController)
    func selectButtonPressed(image: UIImage, withCropRect: CGRect)
}
