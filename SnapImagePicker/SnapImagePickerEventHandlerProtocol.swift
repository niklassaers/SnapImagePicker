import UIKit

protocol SnapImagePickerEventHandlerProtocol: class {
    func viewWillAppearWithCellSize(cellSize: CGFloat)
    func albumIndexClicked(index: Int)
    func albumTitleClicked(destinationViewController: UIViewController)
    func selectButtonPressed(image: UIImage, withImageOptions: ImageOptions)
}
