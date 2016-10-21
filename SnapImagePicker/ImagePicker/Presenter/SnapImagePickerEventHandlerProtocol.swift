import UIKit

protocol SnapImagePickerEventHandlerProtocol: class {
    var cameraRollAccess: Bool { get set }
    func viewWillAppearWithCellSize(_ cellSize: CGSize)
    func albumImageClicked(_ index: Int) -> Bool
    func numberOfItemsInSection(_ section: Int) -> Int
    func presentCell(_ cell: ImageCell, atIndex: Int) -> ImageCell
    func scrolledToCells(_ range: CountableRange<Int>, increasing: Bool)
    func albumTitlePressed(_ navigationController: UINavigationController?)
}
