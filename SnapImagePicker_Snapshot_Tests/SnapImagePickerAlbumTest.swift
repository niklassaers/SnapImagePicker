@testable import SnapImagePicker
import SnapFBSnapshotBase

class SnapImagePickerAlbumTest: SnapFBSnapshotBase {
    override func setUp() {
        super.setUp()
        
        let bundle = NSBundle(identifier: "com.snapsale.SnapImagePicker")
        let storyboard = UIStoryboard(name: "SnapImagePicker", bundle: bundle)
        if let viewController = storyboard.instantiateViewControllerWithIdentifier("Image Picker View Controller") as? SnapImagePickerViewController {
            sutBackingViewController = viewController
            setup(viewController)
            viewController.state = .Album
            sut = viewController.view
            
            recordMode = super.recordAll || false
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
}


extension SnapImagePickerAlbumTest {
    private func setup(vc: SnapImagePickerViewController) {
        if let image = UIImage(named: "dress.jpg", inBundle: NSBundle(forClass: SnapImagePickerAlbumTest.self), compatibleWithTraitCollection: nil) {
            vc.eventHandler = self
            let mainImage = SnapImagePickerImage(image: image, localIdentifier: "localIdentifier", createdDate: NSDate())
            vc.display(SnapImagePickerViewModel(albumTitle: "Title", mainImage: mainImage, selectedIndex: 0, isLoading: false))
        }
    }
}

extension SnapImagePickerAlbumTest: SnapImagePickerEventHandlerProtocol {
    func viewWillAppearWithCellSize(cellSize: CGFloat) {
        
    }
    func albumImageClicked(index: Int) -> Bool {
        return false
    }
    func albumTitleClicked(destinationViewController: UIViewController) {
        
    }
    func selectButtonPressed(image: UIImage, withImageOptions: ImageOptions) {
        
    }
    func numberOfSectionsForNumberOfColumns(columns: Int) -> Int {
        return 40
    }
    func numberOfItemsInSection(section: Int, withColumns: Int) -> Int {
        return withColumns
    }
    func presentCell(cell: ImageCell, atIndex: Int) -> ImageCell {
        cell.imageView?.image = UIImage(named: "dress.jpg", inBundle: NSBundle(forClass: SnapImagePickerAlbumTest.self), compatibleWithTraitCollection: nil)
        if atIndex == 0 {
            cell.backgroundColor = SnapImagePicker.Theme.color
            cell.spacing = 2
        }
        
        return cell
    }
    func scrolledToCells(cells: Range<Int>, increasing: Bool, fromOldRange: Range<Int>?) { }
}
