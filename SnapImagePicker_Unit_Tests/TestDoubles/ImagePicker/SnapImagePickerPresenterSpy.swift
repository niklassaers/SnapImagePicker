import UIKit
@testable import SnapImagePicker

class SnapImagePickerPresenterSpy {
    var presentAlbumCount = 0
    var presentAlbumType: AlbumType?
    var presentAlbumImage: SnapImagePickerImage?
    var presentAlbumSize: Int?
    
    var presentMainImageCount = 0
    var presentMainImageImage: SnapImagePickerImage?
    var presentMainImageType: AlbumType?
    
    var presentAlbumImagesCount = 0
    var presentAlbumImagesResults: [Int: SnapImagePickerImage]?
    var presentAlbumImagesType: AlbumType?
    
    var viewDidLoadCount = 0
    
    var viewWillAppearWithCellSizeCount = 0
    var viewWillAppearWithCellSizeSize: CGSize?
    
    var albumImageClickedCount = 0
    var albumImageClickedIndex: Int?
    
    var numberOfItemsInSectionCount = 0
    var numberOfItemsInSectionSection: Int?
    var numberOfItemsInSectionColumns: Int?
    
    var presentCellCount = 0
    var presentCellCell: ImageCell?
    var presentCellIndex: Int?
    
    var scrolledToCellsCount = 0
    var scrolledToCellsRange: Range<Int>?
    var scrolledToCellsIncreasing: Bool?
    
    var albumTitlePressedCount = 0
    
    var selectButtonPressedCount = 0
    var selectButtonPressedImage: UIImage?
    var selectButtonPressedOptions: ImageOptions?
    
    var dismissCount = 0
    
    var _cameraRollAvailable = false
    var cameraRollAvailableGetCount = 0
    var cameraRollAvailableSetCount = 0
}

extension SnapImagePickerPresenterSpy: SnapImagePickerPresenterProtocol {
    func presentAlbum(album: AlbumType, withMainImage mainImage: SnapImagePickerImage, albumSize: Int) {
        presentAlbumCount += 1
        presentAlbumType = album
        presentAlbumImage = mainImage
        presentAlbumSize = albumSize
    }
    
    func presentMainImage(image: SnapImagePickerImage, fromAlbum album: AlbumType) {
        presentMainImageCount += 1
        presentMainImageImage = image
        presentMainImageType = album
    }
    
    func presentAlbumImages(results: [Int: SnapImagePickerImage], fromAlbum album: AlbumType) {
        presentAlbumImagesCount += 1
        presentAlbumImagesResults = results
        presentAlbumImagesType = album
    }
}

extension SnapImagePickerPresenterSpy: SnapImagePickerEventHandlerProtocol {
    var cameraRollAvailable: Bool {
        get {
            cameraRollAvailableGetCount += 1
            return _cameraRollAvailable
        }
        set {
            cameraRollAvailableSetCount += 1
            _cameraRollAvailable = newValue
        }
    }
    func viewDidLoad() {
        viewDidLoadCount += 1
    }
    
    func viewWillAppearWithCellSize(cellSize: CGSize) {
        viewWillAppearWithCellSizeCount += 1
        viewWillAppearWithCellSizeSize = cellSize
    }
    
    func albumImageClicked(index: Int) {
        albumImageClickedCount += 1
        albumImageClickedIndex = index
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        numberOfItemsInSectionCount += 1
        numberOfItemsInSectionSection = section
        
        return 0
    }
    
    func presentCell(cell: ImageCell, atIndex: Int) -> ImageCell {
        presentCellCount += 1
        presentCellCell = cell
        presentCellIndex = atIndex
        
        return cell
    }
    
    func scrolledToCells(range: Range<Int>, increasing: Bool) {
        scrolledToCellsCount += 1
        scrolledToCellsRange = range
        scrolledToCellsIncreasing = increasing
    }
    
    func albumTitlePressed(navigationController: UINavigationController?) {
        albumTitlePressedCount += 1
    }
    
    func selectButtonPressed(image: UIImage, withImageOptions options: ImageOptions) {
        selectButtonPressedCount += 1
        selectButtonPressedImage = image
        selectButtonPressedOptions = options
    }
}