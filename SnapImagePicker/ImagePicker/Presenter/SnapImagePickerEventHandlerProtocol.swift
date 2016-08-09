import UIKit

protocol SnapImagePickerEventHandlerProtocol: class {
    var cameraRollAvailable: Bool { get set }
    func viewWillAppearWithCellSize(cellSize: CGSize)
    func albumImageClicked(index: Int) -> Bool
    func numberOfItemsInSection(section: Int) -> Int
    func presentCell(cell: ImageCell, atIndex: Int) -> ImageCell
    func scrolledToCells(range: Range<Int>, increasing: Bool)
    func albumTitlePressed(navigationController: UINavigationController?)
    func selectButtonPressed(image: UIImage, withImageOptions: ImageOptions)
}
