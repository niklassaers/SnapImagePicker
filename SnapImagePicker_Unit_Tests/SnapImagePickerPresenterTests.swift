@testable import SnapImagePicker
import XCTest

class SnapImagePickerPresenterTests: XCTestCase, SnapImagePickerTestExpectationDelegate {
    private var interactor: SnapImagePickerInteractorSpy?
    private var viewController: SnapImagePickerViewControllerSpy?
    private var connector: SnapImagePickerConnectorSpy?
    private var presenter: SnapImagePickerPresenter?
    
    private var asyncExpectation: XCTestExpectation?
    var fulfillExpectation: (Void -> Void)? {
        get {
            return asyncExpectation?.fulfill
        }
    }
    
    override func setUp() {
        super.setUp()
        interactor = SnapImagePickerInteractorSpy(delegate: self)
        viewController = SnapImagePickerViewControllerSpy()
        connector = SnapImagePickerConnectorSpy()
        presenter = SnapImagePickerPresenter(view: viewController!)
        presenter?.interactor = interactor!
        presenter?.connector = connector
    }
    
    override func tearDown() {
        interactor = nil
        viewController = nil
        connector = nil
        presenter = nil
        super.tearDown()
    }
    
    private func createImage() -> UIImage? {
        return UIImage(named: "dummy.jpeg", inBundle: NSBundle(forClass: SnapImagePickerConnector.self), compatibleWithTraitCollection: nil)
    }
    
    func testPresentInitialAlbum() {
        if let rawImage = createImage() {
            var image = SnapImagePickerImage(image: rawImage, localIdentifier: "localIdentifier", createdDate: NSDate())
            var albumSize = 30
            
            presenter?.presentInitialAlbum(image, albumSize: albumSize)
            
            XCTAssertEqual(1, viewController?.displayCount, "Presenter.presentInitialAlbum does not trigger ViewController.display")
            let viewModel = viewController?.displayViewModel
            
            XCTAssertNotNil(viewModel, "Presenter.presentInitialAlbum does not send a ViewModel to ViewController")
            XCTAssertEqual(AlbumType.AllPhotos.getAlbumName(), viewModel?.albumTitle, "Presenter does not default to \"All Photos\" as a title")
            XCTAssertEqual(image.image, viewModel?.mainImage?.image, "ViewModel contains wrong image after Presenter.presentInitialAlbum")
            XCTAssertEqual(image.localIdentifier, viewModel?.mainImage?.localIdentifier, "ViewModel contains wrong image after Presenter.presentInitialAlbum")
            XCTAssertEqual(image.createdDate, viewModel?.mainImage?.createdDate, "ViewModel contains wrong image after Presenter.presentInitialAlbum")
            XCTAssertEqual(0, viewModel?.selectedIndex, "ViewModel.selectedIndex is not 0 when presenting initial album with size \(albumSize)")
            XCTAssertFalse(viewModel?.isLoading ?? true, "ViewModel.isLoading is true when presenting initial album image")
            XCTAssertEqual(5, presenter?.numberOfSectionsForNumberOfColumns(6), "Presenter returned wrong number of sections")
            XCTAssertEqual(6, presenter?.numberOfItemsInSection(0, withColumns: 6), "Presenter returned wrong number of columns for a non-last section")
            XCTAssertEqual(0, presenter?.numberOfItemsInSection(100, withColumns: 6), "Presenter returned a number of columns for an invalid section")
            XCTAssertEqual(2, presenter?.numberOfItemsInSection(4, withColumns: 7), "Presenter returned wrong number of columns in the last section")
            
            image = SnapImagePickerImage(image: rawImage, localIdentifier: "localIdentifier2", createdDate: NSDate())
            albumSize = 20
            
            presenter?.presentInitialAlbum(image, albumSize: albumSize)
            XCTAssertEqual(2, viewController?.displayCount, "Presenter.presentInitialAlbum did not trigger ViewController.display")
        } else {
            XCTAssertTrue(false, "Unable to load image")
        }
    }
    
    func testPresentMainImage() {
        if let rawImage = createImage() {
            let image = SnapImagePickerImage(image: rawImage, localIdentifier: "localIdentifier", createdDate: NSDate())
            let mainImage = SnapImagePickerImage(image: rawImage, localIdentifier: "mainImage", createdDate: NSDate())
            
            var result = presenter?.presentMainImage(image)
            XCTAssertEqual(0, viewController?.displayCount, "Presenter.presentMainImage with invalid main image did trigger ViewController.display")
            XCTAssertFalse(result ?? true, "Presenter returned true when setting a non-requested main image")
            
            let size = 5
            let index = size - 1
            
            presenter?.presentInitialAlbum(image, albumSize: size)
            XCTAssertEqual(1, viewController?.displayCount, "Presenter.presentInitialAlbum did not trigger ViewController.display")
            
            presenter?.presentAlbumImage(mainImage, atIndex: index)
            presenter?.albumImageClicked(index)
            XCTAssertEqual(3, viewController?.displayCount, "Presenter.albumImageClicked did not trigger ViewController.display")
            XCTAssertEqual(index, viewController?.displayViewModel?.selectedIndex, "ViewModel.selectedImage does not match last clicked index")
            XCTAssertTrue(viewController?.displayViewModel?.isLoading ?? false, "ViewModel.isLoading set to false after requesting a new image")
            
            result = presenter?.presentMainImage(mainImage)
            XCTAssertTrue(result ?? false, "Presenter returned false when setting a requested main image")
            XCTAssertEqual(4, viewController?.displayCount, "Presenter.presentMainImage did not trigger ViewController.display")
            XCTAssertEqual(mainImage.image, viewController?.displayViewModel?.mainImage?.image, "ViewModel did not contain the latest requested main image")
            XCTAssertEqual(mainImage.localIdentifier, viewController?.displayViewModel?.mainImage?.localIdentifier, "ViewModel did not contain the latest requested main image")
            XCTAssertFalse(viewController?.displayViewModel?.isLoading ?? true, "ViewModel.isLoading set to true when displaying the currently requested main image")
        } else {
            XCTAssertTrue(false, "Unable to load image")
        }
    }
    
    func testPresentAlbumImage() {
        if let rawImage = createImage() {
            let image = SnapImagePickerImage(image: rawImage, localIdentifier: "localIdentifier", createdDate: NSDate())
            
            let size = 5
            let index = size - 1
            
            presenter?.presentInitialAlbum(image, albumSize: size)
            XCTAssertEqual(1, viewController?.displayCount, "Presenter.presentInitialAlbum did no trigger ViewController.display")
            
            var result = presenter?.presentAlbumImage(image, atIndex: size + 1)
            XCTAssertFalse(result ?? true, "Presenter was able to present an album image at an index outside of album size range")
            result = presenter?.presentAlbumImage(image, atIndex: -1)
            XCTAssertFalse(result ?? true, "Presenter was able to present an album image at a negative index")
            
            result = presenter?.presentAlbumImage(image, atIndex: index)
            XCTAssertTrue(result ?? false, "Presenter was unable to present an image in valid album range")
            
            let cell = ImageCellMock()
            presenter?.presentCell(cell, atIndex: index)
            XCTAssertNotNil(cell.imageView?.image, "Presenter returned a cell without an image for a valid index")
        } else {
            XCTAssertTrue(false, "Unable to load image")
        }
    }

    func testViewWillAppearWithCellSize() {
        if let rawImage = createImage() {
            let image = SnapImagePickerImage(image: rawImage, localIdentifier: "localIdentifier", createdDate: NSDate())
            let cellSize = CGFloat(0.0)
            presenter?.viewWillAppearWithCellSize(cellSize)
            presenter?.presentInitialAlbum(image, albumSize: 1)
            presenter?.presentCell(ImageCellMock(), atIndex: 0)
            
            XCTAssertEqual(1, interactor?.loadAlbumImageWithTypeCount, "Presenter.presentCell did not trigger Interactor.loadAlbumImageWithType")
            XCTAssertEqual(CGSize(width: cellSize, height: cellSize), interactor?.loadAlbumImageSize ?? CGSize(width: cellSize + 1000, height: cellSize + 1000), "Presenter did not store use cell width from viewWillAppearWithCellSize when requesting album images")
        } else {
            XCTAssertTrue(false, "Unable to load image")
        }
    }
    
    func testAlbumImageClicked() {
        if let rawImage = createImage() {
            let image = SnapImagePickerImage(image: rawImage, localIdentifier: "localIdentifier", createdDate: NSDate())
            
            var result = presenter?.albumImageClicked(0)
            XCTAssertFalse(result ?? true, "Presenter properly handled click on album image before loading albums")
            
            let size = 5
            let index = size - 1
            
            presenter?.presentInitialAlbum(image, albumSize: size)
            result = presenter?.albumImageClicked(size + 1)
            XCTAssertFalse(result ?? true, "Presenter properly handled click on album image outside of album range")
            
            result = presenter?.albumImageClicked(index)
            XCTAssertFalse(result ?? true, "Presenter properly handled click on an album image which is yet not loaded")
            
            presenter?.presentAlbumImage(image, atIndex: index)
            result = presenter?.albumImageClicked(index)
            XCTAssertTrue(result ?? false, "Presenter was unable to handle click on loaded album image")
            XCTAssertEqual(1, interactor?.loadImageWithLocalIdentifierCount, "Presenter.albumImageClicked did not trigger Interactor.loadImageWithLocalIdentifier")
            XCTAssertEqual(image.localIdentifier, interactor?.loadImageWithLocalIdentifier, "Presenter.albumImageClicked triggered Interactor.loadImageWithLocalIdentifier with the wrong localIdentifier")
        }
    }
    
    func testSelectButtonPressed() {
        if let rawImage = createImage() {
            let options = ImageOptions(cropRect: CGRectZero, rotation: 0)
            
            presenter?.selectButtonPressed(rawImage, withImageOptions: options)
            XCTAssertEqual(1, connector?.setChosenImageCount, "Presenter.selectButtonPressed did not trigger Connector.setChosenImage")
            XCTAssertEqual(rawImage, connector?.setChosenImage, "Presenter.selectButtonPressed triggered Connector.setChosenImage with the wrong image")
            if let connectorOptions = connector?.setChosenImageOptions {
                XCTAssertEqual(options.cropRect, connectorOptions.cropRect, "Presenter.selectButtonPressed triggered Connector.setChosenImage with the wrong options")
                XCTAssertEqual(options.rotation, connectorOptions.rotation, "Presenter.selectButtonPressed triggered Connector.setChosenImage with the wrong options")
            } else {
                XCTAssertTrue(false, "Presenter.selectButtonPressed with options triggered Connector.setChosenImage without options")
            }
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
