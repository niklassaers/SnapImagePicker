@testable import SnapImagePicker
import SnapFBSnapshotBase

class SnapImagePickerImageTest: SnapFBSnapshotBase {
    override func setUp() {
        super.setUp()

        let bundle = NSBundle(identifier: "com.snapsale.SnapImagePicker")
        let storyboard = UIStoryboard(name: "SnapImagePicker", bundle: bundle)
        if let viewController = storyboard.instantiateViewControllerWithIdentifier("Image Picker View Controller") as? SnapImagePickerViewController {
            sutBackingViewController = viewController
            sut = viewController.view
            setup(viewController)
                
            recordMode = super.recordAll || false
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
}


extension SnapImagePickerImageTest {
    private func setup(vc: SnapImagePickerViewController) {
        if let image = UIImage(named: "dress.jpg", inBundle: NSBundle(forClass: SnapImagePickerImageTest.self), compatibleWithTraitCollection: nil) {
            vc.eventHandler = self
            let mainImage = SnapImagePickerImage(image: image, localIdentifier: "localIdentifier", createdDate: NSDate())
            vc.display(SnapImagePickerViewModel(albumTitle: "Title", mainImage: mainImage, selectedIndex: 0, isLoading: false))
        }
    }
}

extension SnapImagePickerImageTest: SnapImagePickerEventHandlerProtocol {
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
        cell.imageView?.image = UIImage(named: "dress.jpg", inBundle: NSBundle(forClass: SnapImagePickerImageTest.self), compatibleWithTraitCollection: nil)
        if atIndex == 0 {
            cell.backgroundColor = SnapImagePickerConnector.Theme.color
            cell.spacing = 2
        }
        
        return cell
    }
}
