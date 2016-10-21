import XCTest
@testable import SnapImagePicker

class SnapImagePickerPresenterTests: XCTestCase {
    fileprivate var viewController: SnapImagePickerViewControllerSpy?
    fileprivate var presenter: SnapImagePickerPresenter?
    
    override func setUp() {
        super.setUp()
        viewController = SnapImagePickerViewControllerSpy()
        presenter = SnapImagePickerPresenter(view: viewController!, cameraRollAccess: true)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    fileprivate func createSnapImagePickerImage(_ image: UIImage = UIImage(), localIdentifier: String = "", createdDate: Date? = nil) -> SnapImagePickerImage {
        return SnapImagePickerImage(image: image, localIdentifier: localIdentifier, createdDate: createdDate as Date?)
    }
    
    fileprivate func presentAlbum(_ albumType: AlbumType = AlbumType.allPhotos, image: UIImage = UIImage(), localIdentifier: String = "", createdDate: Date? = nil, albumSize: Int = 30) {
        let mainImage = createSnapImagePickerImage(image, localIdentifier: localIdentifier, createdDate: createdDate)
        presenter?.presentAlbum(albumType, withMainImage: mainImage, albumSize: albumSize)
    }
    
    func testPresentAlbumShouldSetAlbumSize() {
        let albumSize = 30
        presentAlbum(albumSize: albumSize)
        
        XCTAssertEqual(albumSize, presenter?.numberOfItemsInSection(0))
    }
    
    func testPresentAlbumShouldTriggerDisplayMainImage() {
        let localIdentifier = "local"
        presentAlbum(localIdentifier: localIdentifier)
        
        XCTAssertEqual(1, viewController?.displayMainImageCount)
        XCTAssertNotNil(viewController?.displayMainImageImage)
        XCTAssertEqual(localIdentifier, viewController?.displayMainImageImage?.localIdentifier)
    }
    
    func testPresentAlbumShouldTriggerReloadAlbum() {
        presentAlbum()
        
        XCTAssertEqual(1, viewController?.reloadAlbumCount)
    }
    
    func testPresentMainImageShouldTriggerDisplayMainImage() {
        presenter?.cameraRollAccess = true
        let localIdentifier = "local"
        let albumType = AlbumType.allPhotos
        let mainImage = createSnapImagePickerImage(localIdentifier: localIdentifier)

        presenter?.albumType = albumType
        presenter?.presentMainImage(mainImage, fromAlbum: albumType)
        XCTAssertEqual(1, viewController?.displayMainImageCount)
        XCTAssertEqual(localIdentifier, viewController?.displayMainImageImage?.localIdentifier)
    }
    
    func testPresentAlbumImageShouldTriggerReloadCells() {
        let image = createSnapImagePickerImage()
        let range = 0..<10
        
        var images = [Int: SnapImagePickerImage]()
        var indexes = [Int]()
        for i in range {
            images[i] = image
            indexes.append(i)
        }
        presenter?.cameraRollAccess = true
        
        // Sets up viewIsReady
        presentAlbum()

        // Sets up currentRange
        presenter?.scrolledToCells(0..<10, increasing: true)
        
        presenter?.presentAlbumImages(images, fromAlbum: .allPhotos)
        XCTAssertEqual(1, viewController?.reloadCellAtIndexesCount)
        XCTAssertNotNil(viewController?.reloadCellAtIndexesIndexes)
        XCTAssertEqual(indexes.sorted(), viewController!.reloadCellAtIndexesIndexes!.sorted())
    }
    
    // cameraRollAccess && index < albumSize  && index != selectedIndex
    func testSetAlbumShouldResetSelectedImage() {
        presenter?.cameraRollAccess = true
        presentAlbum()
        presenter?.scrolledToCells(0..<3, increasing: true)
        presenter?.presentAlbumImages([0: createSnapImagePickerImage(), 2: createSnapImagePickerImage()], fromAlbum: .allPhotos)
        
        let cell = ImageCell()
        let _ = presenter?.presentCell(cell, atIndex: 0)
        XCTAssertEqual(2, cell.spacing)
        
        let _ = presenter?.albumImageClicked(2)
        let _ = presenter?.presentCell(cell, atIndex: 2)
        XCTAssertEqual(2, cell.spacing)
        
        presenter?.albumType = .favorites
        presenter?.scrolledToCells(0..<3, increasing: true)
        presenter?.presentAlbumImages([0: createSnapImagePickerImage()], fromAlbum: .favorites)
        
        let _ = presenter?.presentCell(cell, atIndex: 0)
        XCTAssertEqual(2, cell.spacing)
    }
}
