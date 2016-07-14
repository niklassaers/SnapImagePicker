import XCTest

class SnapImagePicker_UI_Tests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSegueToAlbumSelector() {
        let app = XCUIApplication()
        app.buttons["Open Image Picker"].tap()
        let imageCells = app.collectionViews.childrenMatchingType(.Cell)
        XCTAssertTrue(imageCells.count > 0)
        
        let allPhotosButton = app.navigationBars["SnapImagePicker.SnapImagePickerView"].buttons["All Photos"]
        allPhotosButton.tap()
        XCTAssertTrue(imageCells.count == 0)
        
        app.navigationBars["SnapImagePicker.AlbumSelectorView"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        XCTAssertTrue(imageCells.count > 0)
        
        allPhotosButton.tap()
        XCTAssertTrue(imageCells.count == 0)
        
        app.tables.buttons["Album name"].tap()
        XCTAssertTrue(imageCells.count > 0)
    }
//    func testSelectImage() {
//        let app = XCUIApplication()
//        app.buttons["Open Image Picker"].tap()
//        app.navigationBars["SnapImagePicker.SnapImagePickerView"].buttons["Select"].tap()
//        XCTAssertEqual(1, app.otherElements.containingType(.Button, identifier:"Open Image Picker").childrenMatchingType(.Image).count)
//    }
//    
//    func testCancel() {
//        let app = XCUIApplication()
//        app.buttons["Open Image Picker"].tap()
//        app.navigationBars["SnapImagePicker.SnapImagePickerView"].buttons["×"].tap()
//        XCTAssertEqual(0, app.otherElements.containingType(.Button, identifier:"Open Image Picker").childrenMatchingType(.Image).count)
//    }
}