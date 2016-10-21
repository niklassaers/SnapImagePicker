import XCTest
@testable import SnapImagePicker

class SnapImagePickerInteractorTests: XCTestCase {
    var entityGateway: SnapImagePickerEntityGatewaySpy?
    var presenter: SnapImagePickerPresenterSpy?
    var interactor: SnapImagePickerInteractor?
    
    override func setUp() {
        super.setUp()
        entityGateway = SnapImagePickerEntityGatewaySpy()
        presenter = SnapImagePickerPresenterSpy()
        interactor = SnapImagePickerInteractor(presenter: presenter!)
        interactor?.entityGateway = entityGateway
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLoadAlbumShouldTriggerFetchAlbum() {
        let expectation = self.expectation(description: "Waiting for entityGateway.fetchAlbum")
        entityGateway?.expectation = expectation
        
        let albumType = AlbumType.allPhotos
        interactor?.loadAlbum(albumType)
        
        self.waitForExpectations(timeout: 5.0) {
            _ in
            XCTAssertEqual(1, self.entityGateway?.fetchAlbumCount)
            XCTAssertEqual(albumType, self.entityGateway?.fetchAlbumType)
        }
    }
    
    func testLoadedAlbumShouldTriggerPresentAlbum() {
        let albumType = AlbumType.allPhotos
        let mainImage = SnapImagePickerImage(image: UIImage(), localIdentifier: "local", createdDate: nil)
        let albumSize = 30
        
        interactor?.loadedAlbum(albumType, withMainImage: mainImage, albumSize: albumSize)
        XCTAssertEqual(1, presenter?.presentAlbumCount)
        XCTAssertEqual(albumType, presenter?.presentAlbumType)
        XCTAssertEqual(mainImage.localIdentifier, presenter?.presentAlbumImage?.localIdentifier)
        XCTAssertEqual(albumSize, presenter?.presentAlbumSize)
    }
    
    func testLoadAlbumImagesShouldTriggerFetchAlbumImages() {
        let expectation = self.expectation(description: "Waiting for entityGateway.fetchAlbumImages")
        entityGateway?.expectation = expectation
        
        let albumType = AlbumType.allPhotos
        let range = 0..<10
        let targetSize = CGSize(width: 10, height: 10)
        interactor?.loadAlbumImagesFromAlbum(albumType, inRange: range, withTargetSize: targetSize)
        
        self.waitForExpectations(timeout: 5.0) {
            _ in
            XCTAssertEqual(1, self.entityGateway?.fetchAlbumImagesFromAlbumCount)
            XCTAssertEqual(albumType, self.entityGateway?.fetchAlbumImagesFromAlbumType)
            XCTAssertEqual(range, self.entityGateway?.fetchAlbumImagesFromAlbumRange)
            XCTAssertEqual(targetSize, self.entityGateway?.fetchAlbumImagesFromAlbumSize)
        }
    }
    
    func testLoadedAlbumImagesShouldTriggerPresentAlbumImages() {
        let albumType = AlbumType.allPhotos
        var images = [Int: SnapImagePickerImage]()
        for i in 0..<10 {
            images[i] = SnapImagePickerImage(image: UIImage(), localIdentifier: "", createdDate: nil)
        }
        
        interactor?.loadedAlbumImagesResult(images, fromAlbum: albumType)
        XCTAssertEqual(1, presenter?.presentAlbumImagesCount)
        XCTAssertEqual(albumType, presenter?.presentAlbumImagesType)
        XCTAssertEqual(images.count, presenter?.presentAlbumImagesResults?.count)
    }
    
    func testLoadMainImageShouldTriggerFetchMainImage() {
        let expectation = self.expectation(description: "Waiting for entityGateway.fetchMainImage")
        entityGateway?.expectation = expectation
        
        let albumType = AlbumType.allPhotos
        let index = 5
        interactor?.loadMainImageFromAlbum(albumType, atIndex: index)
        
        self.waitForExpectations(timeout: 5.0) {
            _ in
            XCTAssertEqual(1, self.entityGateway?.fetchMainImageFromAlbumCount)
            XCTAssertEqual(albumType, self.entityGateway?.fetchMainImageFromAlbumType)
            XCTAssertEqual(index, self.entityGateway?.fetchMainImageFromAlbumIndex)
        }
    }
    
    func testLoadedMainImageShouldTriggerPresentMainImage() {
        let image = SnapImagePickerImage(image: UIImage(), localIdentifier: "local", createdDate: nil)
        let albumType = AlbumType.allPhotos
        
        interactor?.loadedMainImage(image, fromAlbum: albumType)
        XCTAssertEqual(1, presenter?.presentMainImageCount)
        XCTAssertEqual(albumType, presenter?.presentMainImageType)
        XCTAssertEqual(image.localIdentifier, presenter?.presentMainImageImage?.localIdentifier)
    }
}
