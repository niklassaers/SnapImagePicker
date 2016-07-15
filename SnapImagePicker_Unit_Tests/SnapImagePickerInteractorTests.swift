@testable import SnapImagePicker
import XCTest


class SnapImagePickerInteractorTests: XCTestCase, SnapImagePickerTestExpectationDelegate {
    private var presenter: SnapImagePickerPresenterSpy?
    private var entityGateway: SnapImagePickerEntityGatewaySpy?
    private var interactor: SnapImagePickerInteractor?
    
    private var asyncExpectation: XCTestExpectation?
    var fulfillExpectation: (Void -> Void)? {
        get {
            return asyncExpectation?.fulfill
        }
    }
    
    private let numberOfImages = 30
    
    override func setUp() {
        super.setUp()
        presenter = SnapImagePickerPresenterSpy(delegate: self)
        entityGateway = SnapImagePickerEntityGatewaySpy(delegate: self, numberOfImagesInAlbums: numberOfImages)
        interactor = SnapImagePickerInteractor(presenter: presenter!)
        interactor?.entityGateway = entityGateway
        
    }
    
    override func tearDown() {
        presenter = nil
        entityGateway = nil
        interactor = nil
        super.tearDown()
    }
    
    private func createImage() -> UIImage? {
        return UIImage(named: "dummy.jpeg", inBundle: NSBundle(forClass: SnapImagePicker.self), compatibleWithTraitCollection: nil)
    }

    func testLoadInitialAlbum() {
        let type = AlbumType.AllPhotos
        
        asyncExpectation = expectationWithDescription("Loading initial album")
        interactor?.loadInitialAlbum(type)
        
        self.waitForExpectationsWithTimeout(5) {
            [weak self] error in
            XCTAssertEqual(1, self?.entityGateway?.loadInitialAlbumCount)
            XCTAssertEqual(type, self?.entityGateway?.loadInitialAlbumType)
        }
    }
    
    func testLoadAlbumImageWithType() {
        let type = AlbumType.AllPhotos
        let size = CGSizeZero
        let index = 5
        
        asyncExpectation = expectationWithDescription("Loading a single album image")
        interactor?.loadAlbumImageWithType(type, withTargetSize: size, atIndex: index)
        
        self.waitForExpectationsWithTimeout(5) {
            [weak self] error in
            XCTAssertEqual(1, self?.entityGateway?.loadAlbumImageWithTypeCount)
            XCTAssertEqual(type, self?.entityGateway?.loadAlbumImageType)
            XCTAssertEqual(size, self?.entityGateway?.loadAlbumImageSize)
            XCTAssertEqual(index, self?.entityGateway?.loadAlbumImageAtIndex)
        }
    }
    
    func testLoadImageWithLocalIdentifier() {
        let localIdentifier = "localIdentifier"
        
        asyncExpectation = expectationWithDescription("Loading main image")
        interactor?.loadImageWithLocalIdentifier(localIdentifier)
        
        self.waitForExpectationsWithTimeout(5) {
            [weak self] error in
            XCTAssertEqual(1, self?.entityGateway?.loadImageWithLocalIdentifierCount)
            XCTAssertEqual(localIdentifier, self?.entityGateway?.loadImageWithLocalIdentifier)
        }
    }
    
    func testClearPendingRequests() {
        asyncExpectation = expectationWithDescription("Clearing pending requests")
        interactor?.clearPendingRequests()
        
        self.waitForExpectationsWithTimeout(5) {
            [weak self] error in
            XCTAssertEqual(1, self?.entityGateway?.clearPendingRequestsCount)
        }
    }
    
    func testInitializedAlbum() {
        if let image = createImage() {
            let albumSize = numberOfImages
            let localIdentifier = "localIdentifier"
            let createdDate = NSDate()
            
            asyncExpectation = expectationWithDescription("Initialized album")
            interactor?.initializedAlbum(SnapImagePickerImage(image: image, localIdentifier: localIdentifier, createdDate: createdDate), albumSize: albumSize)
            
            self.waitForExpectationsWithTimeout(5) {
                [weak self] error in
                XCTAssertEqual(1, self?.presenter?.presentInitialAlbumCount)
                XCTAssertEqual(image, self?.presenter?.presentInitialAlbumImage?.image)
                XCTAssertEqual(localIdentifier, self?.presenter?.presentInitialAlbumImage?.localIdentifier)
                XCTAssertEqual(createdDate, self?.presenter?.presentInitialAlbumImage?.createdDate)
                XCTAssertEqual(albumSize, self?.presenter?.presentInitialAlbumSize)
            }
        } else {
            XCTAssertTrue(false, "Unable to load test image")
        }
    }
    
    func testLoadedAlbumImage() {
        if let image = createImage() {
            let localIdentifier = "localIdentifier"
            let createdDate = NSDate()
            let index = 5
            
            asyncExpectation = expectationWithDescription("Loaded album image")
            interactor?.loadedAlbumImage(SnapImagePickerImage(image: image, localIdentifier: localIdentifier, createdDate: createdDate), atIndex: index)
            
            self.waitForExpectationsWithTimeout(5) {
                [weak self] error in
                XCTAssertEqual(1, self?.presenter?.presentAlbumImageCount)
                XCTAssertEqual(image, self?.presenter?.presentAlbumImage?.image)
                XCTAssertEqual(localIdentifier, self?.presenter?.presentAlbumImage?.localIdentifier)
                XCTAssertEqual(createdDate, self?.presenter?.presentAlbumImage?.createdDate)
                XCTAssertEqual(index, self?.presenter?.presentAlbumImageAtIndex)
            }
        } else {
            XCTAssertTrue(false, "Unable to load test image")
        }
    }
    
    func testLoadedMainImage() {
        if let image = createImage() {
            let localIdentifier = "localIdentifier"
            let createdDate = NSDate()
            
            asyncExpectation = expectationWithDescription("Loaded main image")
            interactor?.loadedMainImage(SnapImagePickerImage(image: image, localIdentifier: localIdentifier, createdDate: createdDate))
            
            self.waitForExpectationsWithTimeout(5) {
                [weak self] error in
                XCTAssertEqual(1, self?.presenter?.presentMainImageCount)
                XCTAssertEqual(image, self?.presenter?.presentMainImage?.image)
                XCTAssertEqual(localIdentifier, self?.presenter?.presentMainImage?.localIdentifier)
                XCTAssertEqual(createdDate, self?.presenter?.presentMainImage?.createdDate)
            }
        } else {
            XCTAssertTrue(false, "Unable to load test image")
        }
    }
}
