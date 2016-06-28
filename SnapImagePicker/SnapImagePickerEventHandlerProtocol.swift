import UIKit

protocol SnapImagePickerEventHandlerProtocol: class {
    var displayState: DisplayState { get }
    func viewWillAppear()
    func albumIndexClicked(index: Int)
    func userScrolledToState(state: DisplayState)
    func albumTitleClicked(destinationViewController: UIViewController)
}
