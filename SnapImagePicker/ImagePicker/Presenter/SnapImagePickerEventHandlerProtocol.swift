import UIKit

protocol SnapImagePickerEventHandlerProtocol: class {
    func viewWillAppearWithCellSize(cellSize: CGFloat)
    func albumImageClicked(index: Int)
    func numberOfSectionsForNumberOfColumns(columns: Int) -> Int
    func numberOfItemsInSection(section: Int, withColumns: Int) -> Int
    func presentCell(cell: ImageCell, atIndex: Int) -> ImageCell
    func scrolledToCells(range: Range<Int>, increasing: Bool)
    func albumTitleClicked(destinationViewController: UIViewController)
    func selectButtonPressed(image: UIImage, withImageOptions options: ImageOptions)
    func dismiss()
}
