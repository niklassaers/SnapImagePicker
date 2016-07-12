@testable import SnapImagePicker
import XCTest

protocol SnapImagePickerInteractorSpyDelegate {
    var testExpectation: (Void -> Void)? { get }
}

class SnapImagePickerEntityGatewayTests: XCTestCase, SnapImagePickerInteractorSpyDelegate {
    private var interactor: SnapImagePickerInteractorSpy?
    private var imageLoader: ImageLoaderStub?
    private var entityGateway: SnapImagePickerEntityGateway?
    
    private var asyncExpectation: XCTestExpectation?
    var testExpectation: (Void -> Void)? {
        get {
            return asyncExpectation?.fulfill
        }
    }
    
    private let numberOfImages = 30
    
    override func setUp() {
        super.setUp()
        interactor = SnapImagePickerInteractorSpy(delegate: self)
        imageLoader = ImageLoaderStub(numberOfImagesInAlbum: numberOfImages)
        entityGateway = SnapImagePickerEntityGateway(interactor: interactor!, imageLoader: imageLoader!)
    }
    
    override func tearDown() {
        interactor = nil
        imageLoader = nil
        entityGateway = nil
        super.tearDown()
    }
    
    func testLoadInitialAlbum() {
        asyncExpectation = expectationWithDescription("Loading album")
        entityGateway?.loadInitialAlbum(AlbumType.AllPhotos)
        
        self.waitForExpectationsWithTimeout(5) {
            [weak self] error in
            XCTAssertEqual(1, self?.interactor?.initializedAlbumCount)
            XCTAssertNotNil(self?.interactor?.initializedAlbumImage)
            XCTAssertEqual(self?.numberOfImages, self?.interactor?.initializedAlbumSize)
        }
    }

    func testLoadAlbumImageWithType() {
        var index = 5
        
        asyncExpectation = expectationWithDescription("Loading a single image with a valid index")
        var result = entityGateway?.loadAlbumImageWithType(AlbumType.AllPhotos, withTargetSize: CGSizeZero, atIndex: index)
        XCTAssertTrue(result ?? false)
        
        self.waitForExpectationsWithTimeout(5) {
            [weak self] error in
            XCTAssertEqual(1, self?.interactor?.loadedAlbumImageCount)
            XCTAssertNotNil(self?.interactor?.loadedAlbumImage)
            XCTAssertEqual(index, self?.interactor?.loadedAlbumImageAtIndex)
        }
        
        index = 15
        asyncExpectation = expectationWithDescription("Loading a second with a valid index")
        result = entityGateway?.loadAlbumImageWithType(AlbumType.AllPhotos, withTargetSize: CGSizeZero, atIndex: index)
        XCTAssertTrue(result ?? false)
        
        self.waitForExpectationsWithTimeout(5) {
            [weak self] error in
            XCTAssertEqual(2, self?.interactor?.loadedAlbumImageCount)
            XCTAssertNotNil(self?.interactor?.loadedAlbumImage)
            XCTAssertEqual(index, self?.interactor?.loadedAlbumImageAtIndex)
        }
        
        let outOfBoundsIndex = numberOfImages + 1
        result = entityGateway?.loadAlbumImageWithType(AlbumType.AllPhotos, withTargetSize: CGSizeZero, atIndex: outOfBoundsIndex)
        XCTAssertFalse(result ?? true, "EntityGateway is able to load image with index larger than the album size")
    }
    
    func testLoadImageWithLocalIdentifier() {
        //TODO
    }
    
    func testClearPendingRequests() {
        entityGateway?.clearPendingRequests()
        XCTAssertTrue(imageLoader?.clearPendingRequestsWasCalled ?? false, "EntityGateway.clearPendingRequests does not trigger ImageLoader.clearPendingRequests")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
