import XCTest
@testable import SnapImagePicker

class SnapImagePickerPresenterTests: XCTestCase {
    private var viewController: SnapImagePickerViewControllerSpy?
    private var presenter: SnapImagePickerPresenter?
    
    override func setUp() {
        super.setUp()
        viewController = SnapImagePickerViewControllerSpy()
        presenter = SnapImagePickerPresenter(view: viewController!, cameraRollAccess: true)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    private func createSnapImagePickerImage(image: UIImage = UIImage(), localIdentifier: String = "", createdDate: NSDate? = nil) -> SnapImagePickerImage {
        return SnapImagePickerImage(image: image, localIdentifier: localIdentifier, createdDate: createdDate)
    }
    
    private func presentAlbum(albumType: AlbumType = AlbumType.AllPhotos, image: UIImage = UIImage(), localIdentifier: String = "", createdDate: NSDate? = nil, albumSize: Int = 30) {
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
        let albumType = AlbumType.AllPhotos
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
        
        presenter?.presentAlbumImages(images, fromAlbum: .AllPhotos)
        XCTAssertEqual(1, viewController?.reloadCellAtIndexesCount)
        XCTAssertNotNil(viewController?.reloadCellAtIndexesIndexes)
        XCTAssertEqual(indexes.sort(), viewController!.reloadCellAtIndexesIndexes!.sort())
    }
    
    // cameraRollAccess && index < albumSize  && index != selectedIndex
    func testSetAlbumShouldResetSelectedImage() {
        presenter?.cameraRollAccess = true
        presentAlbum()
        presenter?.scrolledToCells(0..<3, increasing: true)
        presenter?.presentAlbumImages([0: createSnapImagePickerImage(), 2: createSnapImagePickerImage()], fromAlbum: .AllPhotos)
        
        let cell = ImageCell()
        presenter?.presentCell(cell, atIndex: 0)
        XCTAssertEqual(2, cell.spacing)
        
        presenter?.albumImageClicked(2)
        presenter?.presentCell(cell, atIndex: 2)
        XCTAssertEqual(2, cell.spacing)
        
        presenter?.albumType = .Favorites
        presenter?.scrolledToCells(0..<3, increasing: true)
        presenter?.presentAlbumImages([0: createSnapImagePickerImage()], fromAlbum: .Favorites)
        
        presenter?.presentCell(cell, atIndex: 0)
        XCTAssertEqual(2, cell.spacing)
    }
}
