import XCTest
@testable import SnapImagePicker

class SnapImagePickerEntityGatewayTests: XCTestCase {
    var photoLoader: PhotoLoaderMock?
    var interactor: SnapImagePickerInteractorSpy?
    var entityGateway: SnapImagePickerEntityGateway?
    
    private let numberOfImages = 30
    
    override func setUp() {
        super.setUp()
        photoLoader = PhotoLoaderMock(numberOfImages: numberOfImages)
        interactor = SnapImagePickerInteractorSpy()
        entityGateway = SnapImagePickerEntityGateway(interactor: interactor!, imageLoader: photoLoader)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFetchAlbumShouldTriggerFetchAssetCollectionWithType() {
        let albumType = AlbumType.AllPhotos
        entityGateway?.fetchAlbum(albumType)
        
        XCTAssertEqual(1, photoLoader?.fetchAssetsFromCollectionWithTypeCount)
    }
    
    func testFetchAlbumShouldFetchFirstImage() {
        let albumType = AlbumType.AllPhotos
        entityGateway?.fetchAlbum(albumType)
        
        XCTAssertEqual(1, photoLoader?.loadImageFromAssetCount)
    }
    
    func testFetchAlbumShouldTriggerLoadedAlbum() {
        let albumType = AlbumType.AllPhotos
        entityGateway?.fetchAlbum(albumType)
        
        XCTAssertEqual(1, interactor?.loadedAlbumCount)
        XCTAssertEqual(albumType, interactor?.loadedAlbumType)
        XCTAssertEqual(numberOfImages, interactor?.loadedAlbumSize)
    }
    
    func testFetchAlbumImagesShouldTriggerLoadImagesFromAssets() {
        let albumType = AlbumType.AllPhotos
        let range = 0..<numberOfImages
        let targetSize = CGSizeZero
        entityGateway?.fetchAlbumImagesFromAlbum(albumType, inRange: range, withTargetSize: targetSize)
        
        XCTAssertEqual(1, photoLoader?.loadImagesFromAssetsCount)
        XCTAssertEqual(numberOfImages, photoLoader?.loadImagesFromAssetsAssets?.count)
        XCTAssertEqual(targetSize, photoLoader?.loadImagesFromAssetsSize)
    }
    
    func testFetchAlbumImagesShouldTriggerLoadedAlbumImagesResult() {
        let expectation = self.expectationWithDescription("Waiting for interactor.loadedAlbumImagesResult")
        interactor?.expectation = expectation
        
        let albumType = AlbumType.AllPhotos
        let range = 0..<numberOfImages
        let targetSize = CGSizeZero
        entityGateway?.fetchAlbumImagesFromAlbum(albumType, inRange: range, withTargetSize: targetSize)
        
        self.waitForExpectationsWithTimeout(5.0) {
            _ in
            XCTAssertEqual(1, self.interactor?.loadedAlbumImagesResultCount)
            XCTAssertEqual(self.numberOfImages, self.interactor?.loadedAlbumImagesResultResults?.count)
            XCTAssertEqual(albumType, self.interactor?.loadedAlbumImagesResultType)
        }
    }
    
    func fetchMainImageShouldTriggerFetchAssetCollectionWithType() {
        let albumType = AlbumType.AllPhotos
        let index = 5
        entityGateway?.fetchMainImageFromAlbum(albumType, atIndex: index)
        
        XCTAssertEqual(1, photoLoader?.fetchAssetsFromCollectionWithTypeCount)
    }
    
    func fetchMainImageShouldTriggerLoadImageFromAsset() {
        let albumType = AlbumType.AllPhotos
        let index = 5
        entityGateway?.fetchMainImageFromAlbum(albumType, atIndex: index)
        
        XCTAssertEqual(1, photoLoader?.loadImageFromAssetCount)
    }
    
    func fetchMainImageShouldTriggerLoadedMainImage() {
        let expectation = self.expectationWithDescription("Waiting for loaded main image")
        interactor?.expectation = expectation
        
        let albumType = AlbumType.AllPhotos
        let index = 5
        entityGateway?.fetchMainImageFromAlbum(albumType, atIndex: index)
        
        self.waitForExpectationsWithTimeout(5.0) {
            _ in
            XCTAssertEqual(1, self.interactor?.loadedMainImageCount)
            XCTAssertEqual(albumType, self.interactor?.loadedMainImageType)
        }
    }

//    func fetchMainImageFromAlbum(type: AlbumType, atIndex: Int)
}
