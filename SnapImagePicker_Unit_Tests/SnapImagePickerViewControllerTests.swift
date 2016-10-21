@testable import SnapImagePicker
import XCTest

class SnapImagePickerViewControllerTests: XCTestCase {
    private var eventHandler: SnapImagePickerEventHandlerSpy?
    private var viewController: SnapImagePickerViewController?
    
    override func setUp() {
        super.setUp()
        eventHandler = SnapImagePickerEventHandlerSpy()
        viewController = SnapImagePickerViewController()
        viewController?.eventHandler = eventHandler
    }
    
    override func tearDown() {
        eventHandler = nil
        viewController = nil
        super.tearDown()
    }
    
    func testViewWillAppear() {
        viewController?.viewWillAppear(false)
        
        XCTAssertEqual(1, eventHandler?.viewWillAppearWithCellSizeCount, "ViewController.viewWillAppear did not trigger eventHandler.viewWillAppearWithCellSize")
    }
}
