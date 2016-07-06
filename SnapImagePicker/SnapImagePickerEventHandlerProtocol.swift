import UIKit

protocol SnapImagePickerEventHandlerProtocol: class {
    var displayState: DisplayState { get }
    func viewWillAppear()
    func albumIndexClicked(index: Int)
    func userScrolledToState(state: DisplayState)
    func scrolledToOffsetRatio(ratio: Double)
    func flipImageButtonPressed()
    func albumTitleClicked(destinationViewController: UIViewController)
    func selectButtonPressed(image: UIImage, withCropRect cropRect: CGRect)
}
