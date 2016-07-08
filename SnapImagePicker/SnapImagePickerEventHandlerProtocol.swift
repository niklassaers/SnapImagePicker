import UIKit

protocol SnapImagePickerEventHandlerProtocol: class {
    func viewWillAppearWithCellSize(cellSize: CGFloat)
    func albumImageClicked(index: Int)
    func albumTitleClicked(destinationViewController: UIViewController)
    func selectButtonPressed(image: UIImage, withImageOptions: ImageOptions)
    func numberOfSectionsForNumberOfColumns(columns: Int) -> Int
    func numberOfItemsInSection(section: Int, withColumns: Int) -> Int
    func presentCell(cell: ImageCell, atIndex: Int) -> ImageCell
    func scrolledToIndex(index: Int)
}
