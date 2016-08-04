import UIKit

protocol SnapImagePickerEventHandlerProtocol: class {
    func viewDidLoad()
    func loadAlbum()
    func clearAlbum()
    func viewWillAppearWithCellSize(cellSize: CGSize)
    func albumImageClicked(index: Int)
    func numberOfItemsInSection(section: Int) -> Int
    func presentCell(cell: ImageCell, atIndex: Int) -> ImageCell
    func scrolledToCells(range: Range<Int>, increasing: Bool)
    func albumTitlePressed(navigationController: UINavigationController?)
    func selectButtonPressed(image: UIImage, withImageOptions: ImageOptions)
}
