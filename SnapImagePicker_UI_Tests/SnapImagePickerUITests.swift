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
        
        let app = XCUIApplication()
        app.buttons["Start image picker"].tap()
        app.navigationBars["All Photos"].buttons["NESTE"].tap()
        
    }
    
    func testChangeStates() {
        
        let app = XCUIApplication()
        app.buttons["Start image picker"].tap()
        
        let collectionViewsQuery = app.collectionViews
        let albumImagePreviewImage = collectionViewsQuery.childrenMatchingType(.Cell).elementBoundByIndex(1).images["Album Image Preview"]
        albumImagePreviewImage.tap()
        app.scrollViews.images["Selected Image"].tap()
        albumImagePreviewImage.tap()
        collectionViewsQuery.childrenMatchingType(.Cell).elementBoundByIndex(3).images["Album Image Preview"].tap()
        
    }
    
    func testPressImages() {
        
        let app = XCUIApplication()
        app.buttons["Start image picker"].tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.childrenMatchingType(.Cell).elementBoundByIndex(3).images["Album Image Preview"].tap()
        collectionViewsQuery.childrenMatchingType(.Cell).elementBoundByIndex(7).images["Album Image Preview"].tap()
        collectionViewsQuery.childrenMatchingType(.Cell).elementBoundByIndex(8).images["Album Image Preview"].tap()
        
    }
    
    func testRotateImage() {
        
        let app = XCUIApplication()
        app.buttons["Start image picker"].tap()
        
        let btnPhotoRotateButton = app.buttons["btn photo rotate"]
        btnPhotoRotateButton.tap()
        btnPhotoRotateButton.tap()
        btnPhotoRotateButton.tap()
        btnPhotoRotateButton.tap()
        btnPhotoRotateButton.tap()
        app.navigationBars["All Photos"].buttons["NESTE"].tap()
        
    }
    
    func testZoom() {
        
        let app = XCUIApplication()
        app.buttons["Start image picker"].tap()
        
        let selectedImageImage = app.scrollViews.images["Selected Image"]
        selectedImageImage.tap()
        selectedImageImage.tap()
        
    }
}
