import XCTest
@testable import SnapImagePicker

class SnapImagePickerViewControllerTests: XCTestCase {
    var viewController: SnapImagePickerViewController?
    var presenter: SnapImagePickerPresenterSpy?

    override func setUp() {
        super.setUp()
        
        viewController = setupViewController()
        presenter = SnapImagePickerPresenterSpy()
        viewController?.eventHandler = presenter
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    fileprivate func setupViewController() -> SnapImagePickerViewController? {
        let bundle = Bundle(for: SnapImagePickerViewController.self)
        let storyboard = UIStoryboard(name: SnapImagePickerConnector.Names.SnapImagePickerStoryboard.rawValue, bundle: bundle)
        if let snapImagePickerViewController = storyboard.instantiateInitialViewController() as? SnapImagePickerViewController {
            return snapImagePickerViewController
        }
        return nil
    }
    
    func test() {
        if let viewController = viewController {
            viewController.albumCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: UICollectionViewFlowLayout())
            viewController.reloadCellAtIndexes([0, 1])
        } else {
            XCTFail("Unable to load viewController")
        }
    }
}
