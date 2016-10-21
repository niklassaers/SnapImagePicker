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
        camerarollNavigationBar.children(matching: .button).matching(identifier: "Back").element(boundBy: 0).tap()
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
        let albumImagePreviewImage = collectionViewsQuery.children(matching: .cell).element(boundBy: 1).images["Album Image Preview"]
        albumImagePreviewImage.tap()
        app.scrollViews.images["Selected Image"].tap()
        albumImagePreviewImage.tap()
        collectionViewsQuery.children(matching: .cell).element(boundBy: 3).images["Album Image Preview"].tap()
        
    }
    
    func testPressImages() {
        
        let app = XCUIApplication()
        app.buttons["Start image picker"].tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.children(matching: .cell).element(boundBy: 3).images["Album Image Preview"].tap()
        collectionViewsQuery.children(matching: .cell).element(boundBy: 7).images["Album Image Preview"].tap()
        collectionViewsQuery.children(matching: .cell).element(boundBy: 8).images["Album Image Preview"].tap()
        
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
