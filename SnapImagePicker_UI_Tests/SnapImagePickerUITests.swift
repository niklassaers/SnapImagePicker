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
        app.buttons["Load"].tap()
        app.buttons["Start image picker"].tap()
        
        let allPhotosButton = app.navigationBars["All Photos"].buttons["All Photos"]
        allPhotosButton.tap()
        app.navigationBars["Cameraroll"].buttons["Cameraroll"].tap()
        allPhotosButton.tap()
        app.tables.staticTexts["247 images"].tap()
    }
    
    func testSelectImage() {
        let app = XCUIApplication()
        app.buttons["Load"].tap()
        app.buttons["Start image picker"].tap()
        app.navigationBars["All Photos"].buttons["Select"].tap()
    }
    
    func testChangeStates() {
        let app = XCUIApplication()
        app.buttons["Load"].tap()
        app.buttons["Start image picker"].tap()
        app.collectionViews.childrenMatchingType(.Cell).elementBoundByIndex(7).images["Album Image Preview"].tap()
        app.scrollViews.images["Selected Image"].tap()
    }
    
    func testChooseImages() {
        let app = XCUIApplication()
        app.buttons["Load"].tap()
        app.buttons["Start image picker"].tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.childrenMatchingType(.Cell).elementBoundByIndex(4).images["Album Image Preview"].tap()
        collectionViewsQuery.childrenMatchingType(.Cell).elementBoundByIndex(9).images["Album Image Preview"].tap()
        collectionViewsQuery.childrenMatchingType(.Cell).elementBoundByIndex(13).images["Album Image Preview"].tap()
    }
    
    func testRotateImage() {
        let app = XCUIApplication()
        app.buttons["Load"].tap()
        app.buttons["Start image picker"].tap()
        
        let rotateButton = app.buttons["Rotate"]
        rotateButton.tap()
        rotateButton.tap()
        rotateButton.tap()
        rotateButton.tap()
    }
}
