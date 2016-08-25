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
        app.buttons["Start image picker"].tap()
        
        let allPhotosButton = app.navigationBars["All Photos"].buttons["All Photos"]
        allPhotosButton.tap()
        
        let camerarollNavigationBar = app.navigationBars["Cameraroll"]
        camerarollNavigationBar.buttons["Cameraroll"].tap()
        allPhotosButton.tap()
        camerarollNavigationBar.childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        allPhotosButton.tap()
        app.tables.buttons["Album name"].tap()
        
    }
    
    func testSelectImage() {
        
    }
    
    func testChangeStates() {

    }
    
    func testPressImages() {

    }
    
    func testRotateImage() {

    }
}
