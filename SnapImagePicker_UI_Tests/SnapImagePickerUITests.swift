import XCTest

class SnapImagePickerUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSegue() {
        let app = XCUIApplication()
        app.buttons["Open Image Picker"].tap()
        
        let allPhotosButton = app.navigationBars["All Photos"].buttons["All Photos"]
        allPhotosButton.tap()
        app.navigationBars["Cameraroll"].buttons["Cameraroll"].tap()
        allPhotosButton.tap()
        app.tables.buttons["Recently Added"].tap()
        app.navigationBars["Recently Added"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
    }
    
    func testSelectImage() {
        let app = XCUIApplication()
        app.buttons["Open Image Picker"].tap()
        app.navigationBars["All Photos"].buttons["Select"].tap()
    }
}
